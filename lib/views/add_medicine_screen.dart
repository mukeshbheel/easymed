import 'package:flutter/material.dart';
import 'package:medicine_app/utils/app_toast.dart';
import 'package:medicine_app/utils/global_functions.dart';
import 'package:medicine_app/views/widgets/common_appbar.dart';
import 'package:uuid/uuid.dart';
import '../models/medicine_model.dart';
import '../services/medicine_storage.dart';
import '../services/notification_service.dart';
import '../utils/medicine_type.dart';

class AddMedicineScreen extends StatefulWidget {
  final MedicineModel? medicine;

  const AddMedicineScreen({
    super.key,
    this.medicine,
  });

  @override
  State<AddMedicineScreen> createState() => _AddMedicineScreenState();
}

class _AddMedicineScreenState extends State<AddMedicineScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _dosageController = TextEditingController();

  final List<TimeOfDay> _times = [];
  DateTime _startDate = DateTime.now();
  DateTime? _endDate;
  MedicineType _selectedType = MedicineType.tablet;
  int _repeatIntervalDays = 1;
  bool isSavingMedicine = false;

  @override
  void initState() {
    super.initState();

    final medicine = widget.medicine;
    if (medicine != null) {
      _nameController.text = medicine.name;
      _dosageController.text = medicine.dosage;
      _startDate = medicine.startDate;
      _endDate = medicine.endDate;
      _selectedType = medicine.type;

      _times.clear();
      for (final t in medicine.times) {
        _times.add(_parseTime(t));
      }
      _repeatIntervalDays = medicine.repeatIntervalDays;
    }
  }

  TimeOfDay _parseTime(String time) {
    // New format: "HH:mm"
    if (!time.contains('AM') && !time.contains('PM')) {
      final parts = time.split(':');
      return TimeOfDay(
        hour: int.parse(parts[0]),
        minute: int.parse(parts[1]),
      );
    }

    // Old format: "h:mm AM/PM"
    final regExp = RegExp(r'(\d+):(\d+)\s*(AM|PM)');
    final match = regExp.firstMatch(time);

    if (match == null) {
      throw FormatException("Invalid time format: $time");
    }

    int hour = int.parse(match.group(1)!);
    final int minute = int.parse(match.group(2)!);
    final String period = match.group(3)!;

    if (period == 'PM' && hour != 12) hour += 12;
    if (period == 'AM' && hour == 12) hour = 0;

    return TimeOfDay(hour: hour, minute: minute);
  }

  Future<void> _pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (time != null) {
      setState(() => _times.add(time));
    }
  }

  Future<void> _pickStartDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (date != null) {
      setState(() => _startDate = date);
    }
  }

  Future<void> _pickEndDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _endDate ?? _startDate,
      firstDate: _startDate,
      lastDate: DateTime(2100),
    );

    if (date != null) {
      setState(() => _endDate = date);
    }
  }

  Future<void> _saveMedicine() async {
    try{
      if (!_formKey.currentState!.validate() || _times.isEmpty) {
        AppToast.showError("Please complete all required fields");
        return;
      }

      setState(() {
        isSavingMedicine = true;
      });

      final isEdit = widget.medicine != null;
      late MedicineModel medicine;

      // ---------- NORMALIZE TIMES (STORE HH:mm) ----------
      final normalizedTimes = _times
          .map((t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}')
          .toList();

      if (isEdit) {
        medicine = widget.medicine!;

        // Cancel only this medicine notifications
        await NotificationService.cancelMedicineNotifications(medicine);

        medicine
          ..name = _nameController.text.trim()
          ..dosage = _dosageController.text.trim()
          ..times = normalizedTimes
          ..startDate = _startDate
          ..endDate = _endDate
          ..type = _selectedType
          ..repeatIntervalDays = _repeatIntervalDays;

        await medicine.save();
      } else {
        medicine = MedicineModel(
          id: const Uuid().v4(),
          name: _nameController.text.trim(),
          dosage: _dosageController.text.trim(),
          times: normalizedTimes,
          startDate: _startDate,
          endDate: _endDate,
          type: _selectedType,
          repeatIntervalDays: _repeatIntervalDays,
          notificationIds: [],
        );

        await MedicineStorage.add(medicine);
      }

      // ---------- SCHEDULING ----------

      final reminderDates = GlobalFunctions.generateReminderDates(
        start: medicine.startDate,
        end: medicine.endDate,
        intervalDays: medicine.repeatIntervalDays,
        maxDaysAhead: 30, // prevents Android alarm limits
      );

      medicine.notificationIds.clear();

      for (final date in reminderDates) {
        for (final timeStr in medicine.times) {

          // parse HH:mm safely
          final parts = timeStr.split(':');
          final hour = int.parse(parts[0]);
          final minute = int.parse(parts[1]);

          final scheduledDate = DateTime(
            date.year,
            date.month,
            date.day,
            hour,
            minute,
          );

          if (scheduledDate.isBefore(DateTime.now())) continue;

          final notificationId =
              '${medicine.id}_${scheduledDate.millisecondsSinceEpoch}'.hashCode;

          await NotificationService.scheduleNotification(
            id: notificationId,
            title: "Medicine Reminder",
            body: "${medicine.name} • ${medicine.dosage}",
            dateTime: scheduledDate,
            medicineId: medicine.id,
          );

          medicine.notificationIds.add(notificationId);
        }
      }

      await medicine.save();
      AppToast.showSuccess("Medicine Saved");
    }finally{
      setState(() {
        isSavingMedicine = false;
      });
    }

    Navigator.pop(context);
  }

  void _showRepeatPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => SafeArea(
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: 30,
          itemBuilder: (_, index) {
            final value = index + 1;
            final isSelected = value == _repeatIntervalDays;

            return ListTile(
              title: Text("Every $value day${value > 1 ? 's' : ''}"),
              trailing: isSelected
                  ? const Icon(Icons.check, color: Color(0xFF6A5AE0))
                  : null,
              onTap: () {
                setState(() => _repeatIntervalDays = value);
                Navigator.pop(context);
              },
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // _Header(),
          CommonAppBar(
            title: "Add Medicine",
          ),

          const SizedBox(height: 24),
      
          Expanded(
            child: SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    spacing: 16,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SoftLabelInput(
                        label: "Medicine Name",
                        hint: "e.g., Aspirin",
                        controller: _nameController,
                      ),
                    
                      SoftLabelInput(
                        label: "Dosage",
                        hint: "e.g., 100mg",
                        controller: _dosageController,
                      ),
                    
                      _TimesSection(),
                    
                      _RepeatIntervalSection(),
                    
                      Row(
                        children: [
                          Expanded(
                            child: SoftDateInput(
                              label: "Start Date",
                              value:
                              "${_startDate.day}/${_startDate.month}/${_startDate.year}",
                              onTap: _pickStartDate,
                            ),
                          ),

                          const SizedBox(width: 16),

                          Expanded(
                            child: SoftDateInput(
                              label: "End Date (Optional)",
                              value: _endDate == null
                                  ? "Not set"
                                  : "${_endDate!.day}/${_endDate!.month}/${_endDate!.year}",
                              onTap: _pickEndDate,
                            ),
                          ),
                        ],
                      ),
                    
                      MedicineTypeSelector(
                        selectedType: _selectedType,
                        onChanged: (type) {
                          setState(() => _selectedType = type);
                        },
                      ),
                      
                    ],
                  ),
                ),
              ),
            ),
          ),
          Padding(

            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            child: _PrimaryButton(
              isLoading: isSavingMedicine,
              text: widget.medicine == null
                  ? "Add Medicine"
                  : "Update Medicine",
              onTap: _saveMedicine,
            ),
          ),
        ],
      ),
    );
  }

  Widget _TimesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Text(
          "Times",
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade500,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),

        // Field container
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 10,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: Colors.grey.shade300,
            ),
          ),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              // Existing times
              ..._times.map(
                    (t) => _TimePill(
                  label: t.format(context),
                  onRemove: () {
                    setState(() => _times.remove(t));
                  },
                ),
              ),

              // Add time pill (ONLY this opens picker)
              GestureDetector(
                onTap: _pickTime,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.add, size: 16, color: Colors.grey),
                      SizedBox(width: 4),
                      Text(
                        "Add time",
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _RepeatIntervalSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Repeat",
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade500,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),

        InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: _showRepeatPicker,
          child: Container(
            height: 54,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    "Every $_repeatIntervalDays day${_repeatIntervalDays > 1 ? 's' : ''}",
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                ),
                const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: Colors.grey,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

}

class SoftLabelInput extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final TextInputType keyboardType;

  const SoftLabelInput({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade500,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),

        // Input
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: (v) => v == null || v.isEmpty ? "Required" : null,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: Colors.grey.shade400,
              fontSize: 14,
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide(
                color: Colors.grey.shade300,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(
                color: Color(0xFF6A5AE0), // accent
                width: 1.2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(
                color: Colors.redAccent,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class SoftDateInput extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;
  final bool isPlaceholder;

  const SoftDateInput({
    super.key,
    required this.label,
    required this.value,
    required this.onTap,
    this.isPlaceholder = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label (same as text input)
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade500,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),

        // Field
        InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Container(
            height: 54,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: Colors.grey.shade300,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value,
                    style: TextStyle(
                      fontSize: 14,
                      color: isPlaceholder
                          ? Colors.grey.shade400
                          : Colors.black87,
                    ),
                  ),
                ),
                const Icon(
                  Icons.calendar_today_rounded,
                  size: 18,
                  color: Colors.grey,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final bool isLoading;

  const _PrimaryButton({required this.text, required this.onTap, this.isLoading = false});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isLoading ? null : onTap,
      splashColor: Colors.white,
      child: Container(
        height: 54,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            colors: [Color(0xFF6A5AE0), Color(0xFF8E7BFF)],
          ),
        ),
        alignment: Alignment.center,
        child: isLoading ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5,),) : Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _TimePill extends StatelessWidget {
  final String label;
  final VoidCallback onRemove;

  const _TimePill({
    required this.label,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF6A5AE0).withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Color(0xFF6A5AE0),
            ),
          ),
          const SizedBox(width: 6),

          // ✅ PROPER TAP TARGET
          InkWell(
            onTap: onRemove,
            borderRadius: BorderRadius.circular(12),
            child: const Padding(
              padding: EdgeInsets.all(4), // 🔑 increases hit area
              child: Icon(
                Icons.close,
                size: 14,
                color: Color(0xFF6A5AE0),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MedicineTypeSelector extends StatelessWidget {
  final MedicineType selectedType;
  final ValueChanged<MedicineType> onChanged;

  const MedicineTypeSelector({
    super.key,
    required this.selectedType,
    required this.onChanged,
  });

  static const items = [
    (MedicineType.tablet, "Tablet", Icons.remove_circle_outline),
    (MedicineType.injection, "Injection", Icons.vaccines_outlined),
    (MedicineType.capsule, "Capsule", Icons.medication_rounded),
    (MedicineType.spray, "Spray", Icons.air_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      // mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: items.map((item) {
        final isSelected = item.$1 == selectedType;

        return Expanded(
          child: GestureDetector(
            onTap: () => onChanged(item.$1),
            child: Container(
              padding:
              const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF5B4B8A)
                    : Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: isSelected
                    ? [
                  BoxShadow(
                    color: const Color(0xFF5B4B8A)
                        .withOpacity(0.3),
                    blurRadius: 12,
                  )
                ]
                    : [],
              ),
              child: Column(
                children: [
                  Image.asset(
                    GlobalFunctions.getMedicineTypeAsset(item.$1),
                    width: 40,
                    height: 40,
                    // color: isSelected ? Colors.white : Colors.grey,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.$2,
                    style: TextStyle(
                      color:
                      isSelected ? Colors.white : Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

