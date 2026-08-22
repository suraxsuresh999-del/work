/// Tamil Nadu Districts and Cities Data
/// Used for location-based search, filtering, and profiles
class TamilNaduData {
  TamilNaduData._();

  /// All 38 districts of Tamil Nadu
  static const List<String> districts = [
    'Ariyalur',
    'Chengalpattu',
    'Chennai',
    'Coimbatore',
    'Cuddalore',
    'Dharmapuri',
    'Dindigul',
    'Erode',
    'Kallakurichi',
    'Kancheepuram',
    'Kanniyakumari',
    'Karur',
    'Krishnagiri',
    'Madurai',
    'Mayiladuthurai',
    'Nagapattinam',
    'Namakkal',
    'Nilgiris',
    'Perambalur',
    'Pudukkottai',
    'Ramanathapuram',
    'Ranipet',
    'Salem',
    'Sivaganga',
    'Tenkasi',
    'Thanjavur',
    'Theni',
    'Thoothukudi',
    'Tiruchirappalli',
    'Tirunelveli',
    'Tirupathur',
    'Tiruppur',
    'Tiruvallur',
    'Tiruvannamalai',
    'Tiruvarur',
    'Vellore',
    'Viluppuram',
    'Virudhunagar',
  ];

  /// Major cities for quick selection
  static const List<String> majorCities = [
    'Chennai',
    'Coimbatore',
    'Madurai',
    'Tiruchirappalli',
    'Salem',
    'Tirunelveli',
    'Erode',
    'Vellore',
    'Tiruppur',
    'Thoothukudi',
    'Thanjavur',
    'Dindigul',
    'Ranipet',
    'Krishnagiri',
    'Karur',
    'Kancheepuram',
    'Cuddalore',
    'Nagapattinam',
    'Namakkal',
    'Dharmapuri',
  ];

  /// Popular job categories for Tamil Nadu market
  static const List<Map<String, String>> categories = [
    {'id': 'web_dev', 'name': 'Web Development', 'icon': '💻'},
    {'id': 'mobile_dev', 'name': 'Mobile Development', 'icon': '📱'},
    {'id': 'graphic_design', 'name': 'Graphic Design', 'icon': '🎨'},
    {'id': 'content_writing', 'name': 'Content Writing', 'icon': '✍️'},
    {'id': 'digital_marketing', 'name': 'Digital Marketing', 'icon': '📈'},
    {'id': 'video_editing', 'name': 'Video Editing', 'icon': '🎬'},
    {'id': 'photography', 'name': 'Photography', 'icon': '📷'},
    {'id': 'data_entry', 'name': 'Data Entry', 'icon': '📊'},
    {'id': 'translation', 'name': 'Translation (Tamil/English)', 'icon': '🌐'},
    {'id': 'accounting', 'name': 'Accounting & Finance', 'icon': '💰'},
    {'id': 'seo', 'name': 'SEO & SEM', 'icon': '🔍'},
    {'id': 'ui_ux', 'name': 'UI/UX Design', 'icon': '🖌️'},
    {'id': 'social_media', 'name': 'Social Media Management', 'icon': '📲'},
    {'id': 'ecommerce', 'name': 'E-Commerce', 'icon': '🛒'},
    {'id': 'tutoring', 'name': 'Online Tutoring', 'icon': '📚'},
    {'id': 'virtual_assistant', 'name': 'Virtual Assistant', 'icon': '👩‍💼'},
    {'id': 'architecture', 'name': 'Architecture & CAD', 'icon': '🏗️'},
    {'id': 'music', 'name': 'Music & Audio', 'icon': '🎵'},
    {'id': 'legal', 'name': 'Legal Services', 'icon': '⚖️'},
    {'id': 'it_support', 'name': 'IT Support', 'icon': '🖥️'},
  ];

  /// Popular skills
  static const List<String> popularSkills = [
    'Flutter',
    'React',
    'Node.js',
    'Python',
    'Java',
    'Kotlin',
    'Swift',
    'PHP',
    'WordPress',
    'Shopify',
    'Figma',
    'Adobe Photoshop',
    'Adobe Illustrator',
    'After Effects',
    'Premiere Pro',
    'Content Writing',
    'SEO',
    'Google Ads',
    'Facebook Ads',
    'Tamil Translation',
    'Data Entry',
    'Excel',
    'Tally',
    'GST Filing',
    'AutoCAD',
    'Revit',
    'SketchUp',
    'Social Media Marketing',
    'Email Marketing',
    'Video Editing',
  ];

  /// Experience levels
  static const List<Map<String, dynamic>> experienceLevels = [
    {'value': 'entry', 'label': 'Entry Level', 'years': '0-1 years'},
    {'value': 'intermediate', 'label': 'Intermediate', 'years': '1-3 years'},
    {'value': 'experienced', 'label': 'Experienced', 'years': '3-5 years'},
    {'value': 'expert', 'label': 'Expert', 'years': '5+ years'},
  ];

  /// Budget ranges (in INR)
  static const List<Map<String, dynamic>> budgetRanges = [
    {'min': 0, 'max': 5000, 'label': 'Under ₹5,000'},
    {'min': 5000, 'max': 15000, 'label': '₹5,000 - ₹15,000'},
    {'min': 15000, 'max': 50000, 'label': '₹15,000 - ₹50,000'},
    {'min': 50000, 'max': 100000, 'label': '₹50,000 - ₹1,00,000'},
    {'min': 100000, 'max': 500000, 'label': '₹1,00,000 - ₹5,00,000'},
    {'min': 500000, 'max': -1, 'label': '₹5,00,000+'},
  ];

  /// Hourly rates (in INR)
  static const List<Map<String, dynamic>> hourlyRates = [
    {'min': 0, 'max': 200, 'label': 'Under ₹200/hr'},
    {'min': 200, 'max': 500, 'label': '₹200 - ₹500/hr'},
    {'min': 500, 'max': 1000, 'label': '₹500 - ₹1,000/hr'},
    {'min': 1000, 'max': 2500, 'label': '₹1,000 - ₹2,500/hr'},
    {'min': 2500, 'max': 5000, 'label': '₹2,500 - ₹5,000/hr'},
    {'min': 5000, 'max': -1, 'label': '₹5,000+/hr'},
  ];
}
