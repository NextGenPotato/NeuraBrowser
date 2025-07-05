import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PasscodePage extends StatefulWidget {
  final bool isSettingPasscode;

  const PasscodePage({super.key, this.isSettingPasscode = false});

  @override
  State<PasscodePage> createState() => _PasscodePageState();
}

class _PasscodePageState extends State<PasscodePage> {
  String _passcode = '';

  void _onNumberPressed(String value) {
    if (_passcode.length < 4) {
      setState(() {
        _passcode += value;
      });
    }
  }

  void _onDeletePressed() {
    if (_passcode.isNotEmpty) {
      setState(() {
        _passcode = _passcode.substring(0, _passcode.length - 1);
      });
    }
  }

  void _onSubmit() async {
    if (widget.isSettingPasscode) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('passcode', _passcode);
      Navigator.pop(context, true);
    } else {
      final prefs = await SharedPreferences.getInstance();
      final savedPasscode = prefs.getString('passcode');
      if (savedPasscode == _passcode) {
        Navigator.pop(context, true);
      } else {
        setState(() {
          _passcode = '';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Incorrect passcode')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final darkMode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: darkMode ? Colors.grey[900] : Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          widget.isSettingPasscode ? 'Set Passcode' : 'Enter Passcode',
          style: GoogleFonts.lato(
            fontWeight: FontWeight.bold,
            color: darkMode ? Colors.white : Colors.black,
          ),
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Enter your 4-digit passcode',
            style: TextStyle(
              fontSize: 18,
              color: darkMode ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              4,
              (index) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 10),
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: index < _passcode.length
                      ? (darkMode ? Colors.white : Colors.black)
                      : Colors.grey,
                ),
              ),
            ),
          ),
          const SizedBox(height: 40),
          Expanded(
            child: GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                ...List.generate(
                  9,
                  (index) => _buildNumberButton('${index + 1}', darkMode),
                ),
                const SizedBox(),
                _buildNumberButton('0', darkMode),
                _buildDeleteButton(darkMode),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: _onSubmit,
              child: const Text('Submit'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNumberButton(String value, bool darkMode) {
    return TextButton(
      onPressed: () => _onNumberPressed(value),
      child: Text(
        value,
        style: TextStyle(
          fontSize: 24,
          color: darkMode ? Colors.white : Colors.black,
        ),
      ),
    );
  }

  Widget _buildDeleteButton(bool darkMode) {
    return TextButton(
      onPressed: _onDeletePressed,
      child: Icon(
        Icons.backspace,
        color: darkMode ? Colors.white : Colors.black,
      ),
    );
  }
}
