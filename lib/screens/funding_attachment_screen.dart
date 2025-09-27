import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../models/funding_models.dart';
import '../services/database_service.dart';
import '../services/funding_attachment_service.dart';
import '../services/funding_attachment_examples.dart';

/// شاشة إدارة مرفقات التمويل
class FundingAttachmentScreen extends StatefulWidget {
  final int? fundingId; // إذا تم تمرير معرف تمويل محدد

  const FundingAttachmentScreen({
    Key? key,
    this.fundingId,
  }) : super(key: key);

  @override
  _FundingAttachmentScreenState createState() => _FundingAttachmentScreenState();
}

class _FundingAttachmentScreenState extends State<FundingAttachmentScreen> {
  List<FundingAttachment> _attachments = [];
  List<InstitutionFunding> _fundings = [];
  InstitutionFunding? _selectedFunding;
  bool _isLoading = false;
  
  // للبحث
  final _searchController = TextEditingController();
  List<FundingAttachment> _filteredAttachments = [];

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await DatabaseService.initialize();
      
      // تحميل قائمة التمويلات
      final fundings = await DatabaseService.getAllInstitutionFunding();
      setState(() {
        _fundings = fundings;
        
        // تحديد التمويل المحدد إذا تم تمريره
        if (widget.fundingId != null && fundings.isNotEmpty) {
          try {
            _selectedFunding = fundings.firstWhere(
              (f) => f.id == widget.fundingId,
            );
          } catch (e) {
            _selectedFunding = fundings.first;
          }
        } else if (fundings.isNotEmpty) {
          _selectedFunding = fundings.first;
        }
      });

      await _loadAttachments();

    } catch (e) {
      _showErrorSnackBar('خطأ في تحميل البيانات: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadAttachments() async {
    if (_selectedFunding == null) return;

    try {
      final attachments = await FundingAttachmentService.getAttachments(_selectedFunding!.id);
      setState(() {
        _attachments = attachments;
        _applySearch();
      });
    } catch (e) {
      _showErrorSnackBar('خطأ في تحميل المرفقات: $e');
    }
  }

  void _applySearch() {
    final query = _searchController.text.toLowerCase();
    if (query.isEmpty) {
      _filteredAttachments = List.from(_attachments);
    } else {
      _filteredAttachments = _attachments.where((attachment) {
        return attachment.fileName?.toLowerCase().contains(query) == true ||
               attachment.fileType?.toLowerCase().contains(query) == true ||
               attachment.description?.toLowerCase().contains(query) == true;
      }).toList();
    }
  }

  Future<void> _pickAndUploadFile() async {
    if (_selectedFunding == null) {
      _showErrorSnackBar('يرجى اختيار تمويل أولاً');
      return;
    }

    try {
      final result = await FilePicker.platform.pickFiles();
      
      if (result != null && result.files.single.path != null) {
        final file = result.files.single;
        
        await _showUploadDialog(file.path!, file.name);
      }
    } catch (e) {
      _showErrorSnackBar('خطأ في اختيار الملف: $e');
    }
  }

  Future<void> _showUploadDialog(String filePath, String fileName) async {
    final descriptionController = TextEditingController();

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('رفع مرفق جديد'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('اسم الملف: $fileName'),
              SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(
                  labelText: 'وصف المرفق (اختياري)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _uploadFile(filePath, fileName, descriptionController.text);
              },
              child: Text('رفع'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _uploadFile(String filePath, String fileName, String description) async {
    setState(() {
      _isLoading = true;
    });

    try {
      await FundingAttachmentService.uploadAttachment(
        fundingId: _selectedFunding!.id,
        fileName: fileName,
        localFilePath: filePath,
        description: description.isEmpty ? null : description,
      );

      await _loadAttachments();
      _showSuccessSnackBar('تم رفع المرفق بنجاح');

    } catch (e) {
      _showErrorSnackBar('خطأ في رفع المرفق: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteAttachment(FundingAttachment attachment) async {
    final confirmed = await _showConfirmDialog(
      'حذف المرفق',
      'هل أنت متأكد من حذف "${attachment.fileName}"؟',
    );

    if (confirmed == true) {
      try {
        final deleted = await FundingAttachmentService.deleteAttachment(
          attachment.id,
          deleteFile: false, // لا نحذف الملف الفعلي لأمان إضافي
        );

        if (deleted) {
          await _loadAttachments();
          _showSuccessSnackBar('تم حذف المرفق بنجاح');
        } else {
          _showErrorSnackBar('فشل في حذف المرفق');
        }
      } catch (e) {
        _showErrorSnackBar('خطأ في حذف المرفق: $e');
      }
    }
  }

  Future<void> _editAttachmentDescription(FundingAttachment attachment) async {
    final controller = TextEditingController(text: attachment.description ?? '');

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('تعديل وصف المرفق'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('الملف: ${attachment.fileName}'),
              SizedBox(height: 16),
              TextField(
                controller: controller,
                decoration: InputDecoration(
                  labelText: 'وصف المرفق',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _updateDescription(attachment, controller.text);
              },
              child: Text('حفظ'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateDescription(FundingAttachment attachment, String newDescription) async {
    try {
      await FundingAttachmentService.updateAttachmentDescription(
        attachment.id,
        newDescription,
      );

      await _loadAttachments();
      _showSuccessSnackBar('تم تحديث الوصف بنجاح');

    } catch (e) {
      _showErrorSnackBar('خطأ في تحديث الوصف: $e');
    }
  }

  Future<void> _runExamples() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await FundingAttachmentExamples.runCompleteExample();
      await _loadInitialData();
      _showSuccessSnackBar('تم تشغيل الأمثلة وتحديث البيانات');
    } catch (e) {
      _showErrorSnackBar('خطأ في تشغيل الأمثلة: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<bool?> _showConfirmDialog(String title, String message) async {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Text('تأكيد'),
            ),
          ],
        );
      },
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 4),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('إدارة المرفقات'),
        backgroundColor: Colors.teal[600],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadAttachments,
            tooltip: 'تحديث',
          ),
          PopupMenuButton<String>(
            onSelected: (value) async {
              switch (value) {
                case 'examples':
                  await _runExamples();
                  break;
                case 'stats':
                  await _showStats();
                  break;
              }
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem(
                value: 'examples',
                child: ListTile(
                  leading: Icon(Icons.play_arrow),
                  title: Text('تشغيل الأمثلة'),
                ),
              ),
              PopupMenuItem(
                value: 'stats',
                child: ListTile(
                  leading: Icon(Icons.analytics),
                  title: Text('الإحصائيات'),
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // منطقة التحكم
          _buildControlSection(),
          
          // منطقة البحث
          _buildSearchSection(),
          
          // قائمة المرفقات
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : _buildAttachmentsList(),
          ),
        ],
      ),
      floatingActionButton: _selectedFunding != null
          ? FloatingActionButton.extended(
              onPressed: _pickAndUploadFile,
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
              icon: Icon(Icons.add),
              label: Text('إضافة مرفق'),
            )
          : null,
    );
  }

  Widget _buildControlSection() {
    return Container(
      padding: EdgeInsets.all(16),
      color: Colors.grey[100],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'اختيار التمويل',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.teal[800],
            ),
          ),
          SizedBox(height: 8),
          DropdownButtonFormField<InstitutionFunding>(
            value: _selectedFunding,
            decoration: InputDecoration(
              hintText: 'اختر التمويل',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            items: _fundings.map((funding) {
              return DropdownMenuItem<InstitutionFunding>(
                value: funding,
                child: Text('تمويل #${funding.id} - ${funding.allocatedAmount.toStringAsFixed(0)}'),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedFunding = value;
              });
              _loadAttachments();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSearchSection() {
    return Container(
      padding: EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'البحث في المرفقات...',
          prefixIcon: Icon(Icons.search),
          border: OutlineInputBorder(),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _applySearch();
                    });
                  },
                )
              : null,
        ),
        onChanged: (value) {
          setState(() {
            _applySearch();
          });
        },
      ),
    );
  }

  Widget _buildAttachmentsList() {
    if (_selectedFunding == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.attach_file_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            SizedBox(height: 16),
            Text(
              'اختر تمويلاً لعرض مرفقاته',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    if (_filteredAttachments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.folder_open_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            SizedBox(height: 16),
            Text(
              _attachments.isEmpty ? 'لا توجد مرفقات' : 'لا توجد نتائج للبحث',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
            if (_attachments.isEmpty) ...[
              SizedBox(height: 8),
              Text(
                'اضغط على زر "إضافة مرفق" لبدء رفع الملفات',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: _filteredAttachments.length,
      itemBuilder: (context, index) {
        final attachment = _filteredAttachments[index];
        return Card(
          margin: EdgeInsets.only(bottom: 12),
          elevation: 2,
          child: ListTile(
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _getFileTypeColor(attachment.fileType),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _getFileTypeIcon(attachment.fileType),
                color: Colors.white,
                size: 24,
              ),
            ),
            title: Text(
              attachment.fileName ?? 'ملف غير معروف',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (attachment.description != null) ...[
                  Text(
                    attachment.description!,
                    style: TextStyle(color: Colors.grey[600]),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                ],
                Row(
                  children: [
                    Icon(Icons.access_time, size: 16, color: Colors.grey[500]),
                    SizedBox(width: 4),
                    Text(
                      attachment.uploadedAt?.toString().split('.')[0] ?? 'غير محدد',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            trailing: PopupMenuButton<String>(
              onSelected: (value) async {
                switch (value) {
                  case 'edit':
                    await _editAttachmentDescription(attachment);
                    break;
                  case 'delete':
                    await _deleteAttachment(attachment);
                    break;
                }
              },
              itemBuilder: (BuildContext context) => [
                PopupMenuItem(
                  value: 'edit',
                  child: ListTile(
                    leading: Icon(Icons.edit, size: 20),
                    title: Text('تعديل الوصف'),
                  ),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: ListTile(
                    leading: Icon(Icons.delete, size: 20, color: Colors.red),
                    title: Text('حذف', style: TextStyle(color: Colors.red)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _getFileTypeColor(String? fileType) {
    switch (fileType?.toUpperCase()) {
      case 'PDF':
        return Colors.red;
      case 'WORD':
        return Colors.blue;
      case 'EXCEL':
        return Colors.green;
      case 'JPEG':
      case 'PNG':
      case 'GIF':
        return Colors.purple;
      case 'TEXT':
        return Colors.grey;
      case 'ARCHIVE':
        return Colors.orange;
      default:
        return Colors.teal;
    }
  }

  IconData _getFileTypeIcon(String? fileType) {
    switch (fileType?.toUpperCase()) {
      case 'PDF':
        return Icons.picture_as_pdf;
      case 'WORD':
        return Icons.description;
      case 'EXCEL':
        return Icons.table_chart;
      case 'JPEG':
      case 'PNG':
      case 'GIF':
        return Icons.image;
      case 'TEXT':
        return Icons.text_snippet;
      case 'ARCHIVE':
        return Icons.archive;
      default:
        return Icons.attach_file;
    }
  }

  Future<void> _showStats() async {
    try {
      final stats = await DatabaseService.getAttachmentsStats();
      
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('إحصائيات المرفقات'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('إجمالي المرفقات: ${stats['totalAttachments']}'),
                Text('المرفقات الحديثة: ${stats['recentCount']}'),
                SizedBox(height: 16),
                Text('التوزيع حسب النوع:'),
                SizedBox(height: 8),
                ...(stats['typeStats'] as Map<String, int>).entries.map((entry) {
                  return Padding(
                    padding: EdgeInsets.only(left: 16, bottom: 4),
                    child: Text('${entry.key}: ${entry.value}'),
                  );
                }),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('إغلاق'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      _showErrorSnackBar('خطأ في جلب الإحصائيات: $e');
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}