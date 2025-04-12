import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_application_memotrip/models/trip.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_application_memotrip/services/trip_service.dart';

class CreateTripScreen extends StatefulWidget {
  const CreateTripScreen({super.key});

  @override
  State<CreateTripScreen> createState() => _CreateTripScreenState();
}

class _CreateTripScreenState extends State<CreateTripScreen> {
  final TripService _tripService = TripService();
  bool _isCreating = false;
  final TextEditingController _destinationController = TextEditingController();
  final TextEditingController _budgetController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;
  File? _coverImage;
  final ImagePicker _picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // 顶部导航栏
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  // 返回按钮
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Color(0xFFF9FAFB),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_back,
                        color: Color(0xFF374151),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // 标题
                  const Text(
                    '创建新旅程',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                ],
              ),
            ),

            // 表单内容
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 添加封面图片
                    GestureDetector(
                      onTap: _pickCoverImage,
                      child: Container(
                        height: 180,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF9FAFB),
                          borderRadius: BorderRadius.circular(12),
                          image: _coverImage != null
                              ? DecorationImage(
                                  image: FileImage(_coverImage!),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: _coverImage == null
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(
                                    Icons.camera_alt_outlined,
                                    color: Color(0xFF9CA3AF),
                                    size: 32,
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    '添加封面图片',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Color(0xFF9CA3AF),
                                    ),
                                  ),
                                ],
                              )
                            : null,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // 目的地
                    const Text(
                      '目的地',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF374151),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      child: TextField(
                        controller: _destinationController,
                        decoration: const InputDecoration(
                          hintText: '输入旅行目的地',
                          hintStyle: TextStyle(
                            fontSize: 16,
                            color: Color(0xFFD1D5DB),
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // 日期
                    const Text(
                      '日期',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF374151),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        // 开始日期
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _selectDate(context, true),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 14),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border:
                                    Border.all(color: const Color(0xFFE5E7EB)),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _startDate == null
                                        ? 'mm/dd/yyyy'
                                        : DateFormat('MM/dd/yyyy')
                                            .format(_startDate!),
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: _startDate == null
                                          ? const Color(0xFFD1D5DB)
                                          : const Color(0xFF1F2937),
                                    ),
                                  ),
                                  const Icon(
                                    Icons.calendar_today,
                                    color: Color(0xFF9CA3AF),
                                    size: 20,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 16),

                        // 结束日期
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _selectDate(context, false),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 14),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border:
                                    Border.all(color: const Color(0xFFE5E7EB)),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _endDate == null
                                        ? 'mm/dd/yyyy'
                                        : DateFormat('MM/dd/yyyy')
                                            .format(_endDate!),
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: _endDate == null
                                          ? const Color(0xFFD1D5DB)
                                          : const Color(0xFF1F2937),
                                    ),
                                  ),
                                  const Icon(
                                    Icons.calendar_today,
                                    color: Color(0xFF9CA3AF),
                                    size: 20,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // 预算
                    const Text(
                      '预算',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF374151),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      child: TextField(
                        controller: _budgetController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          hintText: '¥ 设置旅行预算',
                          hintStyle: TextStyle(
                            fontSize: 16,
                            color: Color(0xFFD1D5DB),
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // 说明
                    const Text(
                      '说在前面的话',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF374151),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      child: TextField(
                        controller: _noteController,
                        maxLines: 4,
                        decoration: const InputDecoration(
                          hintText: '添加旅行备注',
                          hintStyle: TextStyle(
                            fontSize: 16,
                            color: Color(0xFFD1D5DB),
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 创建按钮
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: _isCreating ? null : _createTrip,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3B82F6),
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  disabledBackgroundColor: Colors.grey[400],
                ),
                child: _isCreating
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          ),
                          SizedBox(width: 12),
                          Text(
                            '创建中...',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      )
                    : const Text(
                        '创建旅程',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 选择日期
  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF3B82F6),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
          // 如果结束日期为空或早于开始日期，则设置结束日期与开始日期相同
          if (_endDate == null || _endDate!.isBefore(_startDate!)) {
            _endDate = _startDate;
          }
        } else {
          // 确保结束日期不早于开始日期
          if (_startDate != null && picked.isBefore(_startDate!)) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('结束日期不能早于开始日期')),
            );
          } else {
            _endDate = picked;
          }
        }
      });
    }
  }

  // 选择封面图片
  Future<void> _pickCoverImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _coverImage = File(image.path);
      });
    }
  }

  // 创建旅程
  Future<void> _createTrip() async {
    // 验证输入
    if (_destinationController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入旅行目的地')),
      );
      return;
    }

    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请选择旅行日期')),
      );
      return;
    }

    // 设置加载状态
    setState(() {
      _isCreating = true;
    });

    try {
      // 将预算字符串转换为 double
      double? budget;
      if (_budgetController.text.isNotEmpty) {
        budget = double.tryParse(_budgetController.text);
        if (budget == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('预算必须是有效的数字')),
          );
          setState(() {
            _isCreating = false;
          });
          return;
        }
      }
      
      // 通过 TripService 创建旅行并上传图片
      final newTrip = await _tripService.createTrip(
        destination: _destinationController.text,
        startDate: _startDate!,
        endDate: _endDate!,
        imageFile: _coverImage,
        budget: budget,
        note: _noteController.text.isNotEmpty ? _noteController.text : null,
      );

      // 返回新创建的旅程
      Navigator.pop(context, newTrip);
    } catch (e) {
      // 处理错误
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('创建旅程失败: $e')),
      );
      
      // 重置加载状态
      setState(() {
        _isCreating = false;
      });
    }
  }
}
