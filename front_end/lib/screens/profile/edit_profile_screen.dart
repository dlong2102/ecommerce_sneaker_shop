import 'package:ecommerce_sneaker_app/screens/auth/change_password.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _imgUrlController;
  late TextEditingController _emailController;
  late TextEditingController _addressController;
  late TextEditingController _dobController;
  late TextEditingController _phoneNumberController;

  @override
  void initState() {
    super.initState();
    final auth = Provider.of<AuthProvider>(context, listen: false);
    _nameController = TextEditingController(text: auth.user?.name ?? '');
    _imgUrlController = TextEditingController(text: auth.user?.imgUrl ?? '');
    _emailController = TextEditingController(text: auth.user?.email ?? '');
    _addressController = TextEditingController(text: auth.user?.address ?? '');
    _phoneNumberController =
        TextEditingController(text: auth.user?.phoneNumber ?? '');

    // Format date to display as dd-MM-yyyy
    final dateFormat = DateFormat('dd-MM-yyyy');
    String formattedDate = '';
    if (auth.user?.dateOfBirth != null) {
      formattedDate = dateFormat.format(auth.user!.dateOfBirth!);
    }
    _dobController = TextEditingController(text: formattedDate);
  }

  void _navigateToChangePassword() {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => ChangePasswordScreen()));
  }

  void _saveChanges() async {
    if (_formKey.currentState?.validate() ?? false) {
      final auth = Provider.of<AuthProvider>(context, listen: false);

      try {
        final dateFormat = DateFormat('dd-MM-yyyy');
        final parsedDate = dateFormat.parseStrict(_dobController.text);

        await auth.updateProfile(
          name: _nameController.text,
          imgUrl: _imgUrlController.text,
          email: _emailController.text,
          phoneNumber: _phoneNumberController.text,
          address: _addressController.text,
          dateOfBirth: parsedDate,
        );

        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.green,
            content: Text('Cập nhật thông tin thành công',
                style: TextStyle(color: Colors.white)),
          ),
        );
      } catch (e) {
        print('Invalid date format: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid date format. Please use YYYY-MM-DD format'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
            image: NetworkImage(
                'https://i.pinimg.com/736x/ec/64/36/ec643677816dbdc95d57d05753be6ce0.jpg'),
            fit: BoxFit.cover),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.green,
            ),
            child: const Text('Sửa Thông tin',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          actions: [
            IconButton(
                icon: const Icon(
                  Icons.lock,
                  color: Colors.white,
                ),
                onPressed: _navigateToChangePassword,
                style: IconButton.styleFrom(
                  padding: const EdgeInsets.all(5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  backgroundColor: Colors.green,
                )),
            const SizedBox(width: 8), // Add some padding on the right
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.only(top: 20),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Chỉnh sửa Thông tin',
                        style: Theme.of(context).textTheme.headlineMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'Name',
                          prefixIcon: const Icon(Icons.person,
                              color: Colors.blue, size: 26),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        validator: (value) =>
                            value?.isEmpty == true ? 'Enter name' : null,
                      ),
                      const SizedBox(height: 15),
                      TextFormField(
                        controller: _imgUrlController,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.all(25),
                          labelText: 'ImgUrl',
                          prefixIcon: _imgUrlController.text.isNotEmpty
                              ? Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: CircleAvatar(
                                    radius: 30,
                                    backgroundImage: _imgUrlController.text
                                            .startsWith('http')
                                        ? NetworkImage(_imgUrlController.text)
                                        : AssetImage(_imgUrlController.text)
                                            as ImageProvider,
                                  ),
                                )
                              : const Icon(Icons.image,
                                  color: Colors.blue, size: 26),
                          suffixIcon: _imgUrlController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    setState(() {
                                      _imgUrlController.clear();
                                    });
                                  },
                                )
                              : null,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onChanged: (value) {
                          setState(
                              () {}); // Trigger rebuild to update prefix icon
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Vui lòng nhập URL hoặc chọn ảnh';
                          }

                          // Kiểm tra URL hợp lệ (http, https) hoặc asset
                          if (!value.startsWith('http') &&
                              !value.startsWith('assets/')) {
                            return 'URL không hợp lệ. Sử dụng URL http/https hoặc đường dẫn asset';
                          }

                          return null;
                        },
                      ),
                      const SizedBox(height: 15),
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          prefixIcon: const Icon(Icons.email,
                              color: Colors.blue, size: 26),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        validator: (value) =>
                            value?.isEmpty == true ? 'Enter email' : null,
                      ),
                      const SizedBox(height: 15),
                      // Phone number field
                      TextFormField(
                        controller: _phoneNumberController,
                        inputFormatters: [
                          FilteringTextInputFormatter
                              .digitsOnly, // Chỉ cho phép nhập số
                          LengthLimitingTextInputFormatter(
                              10), // Giới hạn 10 ký tự
                        ],
                        decoration: InputDecoration(
                          labelText: 'Phone Number',
                          prefixIcon: const Icon(Icons.phone,
                              color: Colors.blue, size: 26),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        validator: (value) => value?.isEmpty == true
                            ? 'Enter phone number'
                            : null,
                      ),
                      const SizedBox(height: 15),
                      TextFormField(
                        controller: _addressController,
                        decoration: InputDecoration(
                          labelText: 'Address',
                          prefixIcon: const Icon(Icons.location_on,
                              color: Colors.blue, size: 26),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      TextFormField(
                        controller: _dobController,
                        decoration: InputDecoration(
                          labelText: 'Date of Birth',
                          prefixIcon: const Icon(Icons.cake,
                              color: Colors.blue, size: 26),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        validator: (value) => value?.isEmpty == true
                            ? 'Enter date of birth'
                            : null,
                      ),
                      const SizedBox(height: 30),
                      ElevatedButton(
                        onPressed: _saveChanges,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          backgroundColor: Colors.green,
                        ),
                        child: const Text(
                          'Save Changes',
                          style: TextStyle(fontSize: 20, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
