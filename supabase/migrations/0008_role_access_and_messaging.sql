-- Role-verified marketplace actions and persistent conversations.

DROP POLICY IF EXISTS "Clients can insert jobs." ON public.jobs;
CREATE POLICY "Verified clients can insert jobs" ON public.jobs
  FOR INSERT TO authenticated
  WITH CHECK (
    auth.uid() = client_id
    AND EXISTS (
      SELECT 1 FROM public.profiles p
      WHERE p.id = auth.uid()
        AND p.user_type = 'client'
        AND p.verification_status = 'approved'
    )
  );

DROP POLICY IF EXISTS "Freelancers can insert applications." ON public.job_applications;
CREATE POLICY "Verified freelancers can insert applications" ON public.job_applications
  FOR INSERT TO authenticated
  WITH CHECK (
    auth.uid() = freelancer_id
    AND EXISTS (
      SELECT 1 FROM public.profiles p
      WHERE p.id = auth.uid()
        AND p.user_type = 'freelancer'
        AND p.verification_status = 'approved'
    )
    AND EXISTS (SELECT 1 FROM public.jobs j WHERE j.id = job_id AND j.status = 'open')
  );

DROP POLICY IF EXISTS "Freelancers can update their assigned projects." ON public.projects;
CREATE POLICY "Verified freelancers can update assigned projects" ON public.projects
  FOR UPDATE TO authenticated
  USING (
    auth.uid() = freelancer_id
    AND EXISTS (
      SELECT 1 FROM public.profiles p
      WHERE p.id = auth.uid()
        AND p.user_type = 'freelancer'
        AND p.verification_status = 'approved'
    )
  );

CREATE OR REPLACE FUNCTION public.get_or_create_direct_conversation(other_user_id UUID)
RETURNS UUID AS $$
DECLARE
  conversation_id UUID;
BEGIN
  IF auth.uid() IS NULL OR other_user_id IS NULL OR other_user_id = auth.uid() THEN
    RAISE EXCEPTION 'A different authenticated user is required';
  END IF;

  IF NOT EXISTS (SELECT 1 FROM public.profiles WHERE id = other_user_id) THEN
    RAISE EXCEPTION 'User not found';
  END IF;

  SELECT cp.conversation_id INTO conversation_id
  FROM public.conversation_participants cp
  WHERE cp.user_id = auth.uid()
    AND EXISTS (
      SELECT 1 FROM public.conversation_participants other_cp
      WHERE other_cp.conversation_id = cp.conversation_id
        AND other_cp.user_id = other_user_id
    )
  LIMIT 1;

  IF conversation_id IS NULL THEN
    INSERT INTO public.conversations DEFAULT VALUES RETURNING id INTO conversation_id;
    INSERT INTO public.conversation_participants (conversation_id, user_id)
    VALUES (conversation_id, auth.uid()), (conversation_id, other_user_id);
  END IF;

  RETURN conversation_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

CREATE OR REPLACE FUNCTION public.get_my_conversations()
RETURNS JSONB AS $$
BEGIN
  IF auth.uid() IS NULL THEN RAISE EXCEPTION 'Authentication is required'; END IF;

  RETURN COALESCE((
    SELECT jsonb_agg(jsonb_build_object(
      'id', c.id,
      'updated_at', c.updated_at,
      'project_id', c.project_id,
      'other_user_id', other_profile.id,
      'other_user_name', other_profile.full_name,
      'other_user_avatar', other_profile.avatar_url,
      'last_message', latest_message.content,
      'last_message_at', latest_message.created_at
    ) ORDER BY COALESCE(latest_message.created_at, c.updated_at) DESC)
    FROM public.conversations c
    JOIN public.conversation_participants mine
      ON mine.conversation_id = c.id AND mine.user_id = auth.uid()
    JOIN public.conversation_participants other_participant
      ON other_participant.conversation_id = c.id AND other_participant.user_id <> auth.uid()
    JOIN public.profiles other_profile ON other_profile.id = other_participant.user_id
    LEFT JOIN LATERAL (
      SELECT m.content, m.created_at FROM public.messages m
      WHERE m.conversation_id = c.id ORDER BY m.created_at DESC LIMIT 1
    ) latest_message ON true
  ), '[]'::jsonb);
END;
$$ LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path = public;

CREATE OR REPLACE FUNCTION public.get_conversation_messages(conversation_id_input UUID)
RETURNS JSONB AS $$
BEGIN
  IF auth.uid() IS NULL OR NOT EXISTS (
    SELECT 1 FROM public.conversation_participants
    WHERE conversation_id = conversation_id_input AND user_id = auth.uid()
  ) THEN
    RAISE EXCEPTION 'Conversation access is not permitted';
  END IF;

  RETURN COALESCE((
    SELECT jsonb_agg(jsonb_build_object(
      'id', m.id, 'sender_id', m.sender_id, 'content', m.content,
      'created_at', m.created_at, 'message_type', m.message_type::TEXT
    ) ORDER BY m.created_at ASC)
    FROM public.messages m WHERE m.conversation_id = conversation_id_input
  ), '[]'::jsonb);
END;
$$ LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path = public;

CREATE OR REPLACE FUNCTION public.send_conversation_message(
  conversation_id_input UUID,
  content_input TEXT
)
RETURNS UUID AS $$
DECLARE message_id UUID;
BEGIN
  IF auth.uid() IS NULL OR length(trim(COALESCE(content_input, ''))) = 0 THEN
    RAISE EXCEPTION 'A message is required';
  END IF;
  IF NOT EXISTS (
    SELECT 1 FROM public.conversation_participants
    WHERE conversation_id = conversation_id_input AND user_id = auth.uid()
  ) THEN RAISE EXCEPTION 'Conversation access is not permitted'; END IF;

  INSERT INTO public.messages (conversation_id, sender_id, content)
  VALUES (conversation_id_input, auth.uid(), trim(content_input)) RETURNING id INTO message_id;
  UPDATE public.conversations SET updated_at = now() WHERE id = conversation_id_input;
  RETURN message_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;
