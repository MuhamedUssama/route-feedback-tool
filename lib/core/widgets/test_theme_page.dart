import 'package:flutter/material.dart';

class TestThemePage extends StatelessWidget {
  const TestThemePage({super.key});

  @override
  Widget build(BuildContext context) {
    // عشان نجرب الـ Dark/Light
    var isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Theme Playground"),
        actions: [
          // زرار وهمي عشان نشوف شكله
          IconButton(onPressed: () {}, icon: const Icon(Icons.settings)),
        ],
      ),
      body: Row(
        children: [
          // Side Panel وهمي عشان نحس بجو الديسكتوب
          Container(
            width: 250,
            color: isDark ? Colors.black12 : Colors.grey[100],
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: const [
                Text(
                  "MENU",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: 16),
                ListTile(
                  leading: Icon(Icons.dashboard),
                  title: Text("Dashboard"),
                  selected: true,
                ),
                ListTile(leading: Icon(Icons.people), title: Text("Students")),
                ListTile(
                  leading: Icon(Icons.settings),
                  title: Text("Settings"),
                ),
              ],
            ),
          ),
          // Content Area
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Typography Check
                  Text(
                    "Typography Check",
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const Divider(),
                  const SizedBox(height: 20),
                  const Text(
                    "This is a Body Text using Inter font. It should be clean and readable for data.",
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Display Large Text",
                    style: Theme.of(context).textTheme.displayLarge,
                  ),
                  Text(
                    "Headline Small Text",
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),

                  const SizedBox(height: 40),

                  // 2. Buttons Check
                  Text(
                    "Buttons & Interactions",
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const Divider(),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () {},
                        child: const Text("Primary Action"),
                      ),
                      const SizedBox(width: 20),
                      ElevatedButton(
                        onPressed: null, // Disabled
                        child: const Text("Disabled"),
                      ),
                      const SizedBox(width: 20),
                      TextButton(
                        onPressed: () {},
                        child: const Text("Secondary Action"),
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),

                  // 3. Inputs Check
                  Text(
                    "Input Fields",
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const Divider(),
                  const SizedBox(height: 20),
                  const SizedBox(
                    width: 400,
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: "Enter Assignment Name",
                        hintText: "e.g. Assignment 5",
                        prefixIcon: Icon(Icons.assignment),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const SizedBox(
                    width: 400,
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: "Error Example",
                        errorText: "This field is required",
                        prefixIcon: Icon(Icons.warning),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // 4. Cards & Colors
                  Text(
                    "Cards & Semantic Colors",
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const Divider(),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      _buildStatusCard(
                        context,
                        "Success",
                        Colors.green,
                        Icons.check_circle,
                      ),
                      const SizedBox(width: 20),
                      _buildStatusCard(
                        context,
                        "Warning",
                        Colors.amber,
                        Icons.warning,
                      ),
                      const SizedBox(width: 20),
                      _buildStatusCard(
                        context,
                        "Error",
                        Colors.red,
                        Icons.error,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard(
    BuildContext context,
    String title,
    Color color,
    IconData icon,
  ) {
    return Card(
      child: Container(
        width: 150,
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(icon, color: color, size: 30),
            const SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(color: color, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
