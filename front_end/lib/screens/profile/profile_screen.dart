import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../auth/login_screen.dart';
import '../payment/payment_list.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
  }

  void _showSignOutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Đăng xuất'),
        content: const Text('Bạn có muốn đăng xuất?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              context.read<AuthProvider>().signOut();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
            child: const Text('Đăng xuất', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, String value) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              _getIconForTitle(title),
              color: Colors.blue,
              size: 36,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForTitle(String title) {
    switch (title.toLowerCase()) {
      case 'name':
        return Icons.person;
      case 'email':
        return Icons.email;
      case 'phone number':
        return Icons.phone;
      case 'date of birth':
        return Icons.cake;
      case 'address':
        return Icons.location_on;
      default:
        return Icons.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Profile', style: TextStyle(fontSize: 26)),
        centerTitle: true,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.edit,
              size: 28,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const EditProfileScreen()),
              ).then((_) async {
                // Gọi hàm lấy lại dữ liệu người dùng khi quay lại trang Profile
                await Provider.of<AuthProvider>(context, listen: false)
                    .getUserProfile();
              });
            },
          ),
        ],
      ),
      body: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          if (auth.user == null) {
            return const Center(child: CircularProgressIndicator());
          }
          return SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.only(
                    top: 18,
                    bottom: 18,
                  ),
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(15)),
                    gradient: LinearGradient(
                      colors: [Colors.blue.shade200, Colors.blue.shade700],
                    ),
                  ),
                  child: Center(
                    child: Column(
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white,
                              width: 3,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                spreadRadius: 2,
                                blurRadius: 5,
                                offset: const Offset(0, 3),
                              ),
                            ],
                            image: DecorationImage(
                              fit: BoxFit.cover,
                              image: auth.user!.imgUrl != null &&
                                      auth.user!.imgUrl!.isNotEmpty
                                  ? NetworkImage(auth.user!.imgUrl!)
                                  : const AssetImage(
                                          'assets/images/default_avatar.jpg')
                                      as ImageProvider,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          auth.user!.name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          auth.user!.email,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                //Phone number field
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: DefaultTabController(
                    length: 2,
                    child: Column(
                      children: [
                        const TabBar(
                          indicatorColor: Colors.green,
                          labelColor: Colors.green,
                          unselectedLabelColor: Colors.grey,
                          tabs: [
                            Tab(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.person, size: 32),
                                  SizedBox(width: 8),
                                  Text('Thông tin',
                                      style: TextStyle(fontSize: 16)),
                                ],
                              ),
                            ),
                            Tab(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.shopping_bag, size: 32),
                                  SizedBox(width: 8),
                                  Text('Lịch sử đặt hàng',
                                      style: TextStyle(fontSize: 16)),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height *
                              0.45, // Adjust height as needed
                          child: TabBarView(
                            children: [
                              // Information Tab
                              SingleChildScrollView(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  children: [
                                    if (auth.user!.phoneNumber != null)
                                      _buildInfoCard('Phone number',
                                          auth.user!.phoneNumber!),
                                    if (auth.user!.dateOfBirth != null)
                                      _buildInfoCard(
                                        'Date of Birth',
                                        '${auth.user!.dateOfBirth!.day.toString().padLeft(2, '0')}/${auth.user!.dateOfBirth!.month.toString().padLeft(2, '0')}/${auth.user!.dateOfBirth!.year}',
                                      ),
                                    if (auth.user!.address != null)
                                      _buildInfoCard(
                                          'Address', auth.user!.address!),
                                    const SizedBox(height: 16),
                                    ElevatedButton(
                                      onPressed: _showSignOutDialog,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 48,
                                          vertical: 12,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                      ),
                                      child: const Text('Đăng xuất',
                                          style: TextStyle(
                                            fontSize: 20,
                                            color: Colors.white,
                                          )),
                                    ),
                                  ],
                                ),
                              ),

                              // Payment List Tab
                              const PaymentListTab()
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
