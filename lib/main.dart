import 'package:flutter/material.dart';

void main() {
  runApp(const SnapExplainApp());
}

class SnapExplainApp extends StatelessWidget {
  const SnapExplainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SnapExplain',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0A101D),
        cardColor: const Color(0xFF131C2E),
        primaryColor: const Color(0xFF2563EB),
      ),
      home: const SnapExplainDashboard(),
    );
  }
}

// --- DATA MODELS ---
class DiagramComponent {
  final String id;
  final String name;
  final Color color;
  final Rect boxRect; // Normalized (0.0 to 1.0) coordinates on canvas
  final Offset badgeOffset; // Normalized (0.0 to 1.0) badge position
  final String whatIsIt;
  final String whyUsed;
  final String connectionInfo;
  final String examNotes;
  final String analogy;

  const DiagramComponent({
    required this.id,
    required this.name,
    required this.color,
    required this.boxRect,
    required this.badgeOffset,
    required this.whatIsIt,
    required this.whyUsed,
    required this.connectionInfo,
    required this.examNotes,
    required this.analogy,
  });
}

class PromptOption {
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;

  const PromptOption({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
  });
}

// --- MAIN DASHBOARD ---
class SnapExplainDashboard extends StatefulWidget {
  const SnapExplainDashboard({super.key});

  @override
  State<SnapExplainDashboard> createState() => _SnapExplainDashboardState();
}

class _SnapExplainDashboardState extends State<SnapExplainDashboard> {
  // 0 = Circuit Diagram, 1 = Biology Cell Diagram
  int _selectedDiagramIndex = 0;

  // Processing simulation state
  bool _isProcessing = false;
  bool _showRawSketch = false;
  bool _showImproperWarning = false;

  // Selected component IDs
  Set<String> _selectedIds = {'resistor', 'led'};

  // Selected question mode
  String _selectedPromptId = 'together';

  final List<PromptOption> _prompts = const [
    PromptOption(
      id: 'what',
      title: 'What is it?',
      subtitle: 'Identify the selected components',
      icon: Icons.inventory_2_outlined,
    ),
    PromptOption(
      id: 'why',
      title: 'Why is it used?',
      subtitle: 'Explain the purpose',
      icon: Icons.verified_outlined,
    ),
    PromptOption(
      id: 'together',
      title: 'How do they work together?',
      subtitle: 'Explain their relationship',
      icon: Icons.link,
    ),
    PromptOption(
      id: 'connection',
      title: 'Explain the connections',
      subtitle: 'How they are connected',
      icon: Icons.hub_outlined,
    ),
    PromptOption(
      id: 'exam',
      title: 'Exam preparation',
      subtitle: 'Short, simple revision notes',
      icon: Icons.description_outlined,
    ),
  ];

  // Circuit Components Data
  final List<DiagramComponent> _circuitComponents = const [
    DiagramComponent(
      id: 'battery',
      name: 'Battery',
      color: Color(0xFFEF4444), // Red
      boxRect: Rect.fromLTWH(0.20, 0.38, 0.11, 0.32),
      badgeOffset: Offset(0.11, 0.39),
      whatIsIt: 'A 9V DC voltage source that supplies electrical energy to the circuit.',
      whyUsed: 'It provides the electromotive force (voltage) needed to push electrons around the loop.',
      connectionInfo: 'Positive (+) terminal connects to the Switch; Negative (-) terminal returns from the LED cathode.',
      examNotes: '• Symbol: Long line (+), short thick line (-).\n• Unit: Volts (V).\n• Converts chemical energy to electrical energy.',
      analogy: 'Think of the battery as a water pump that creates pressure to push water through pipes.',
    ),
    DiagramComponent(
      id: 'switch',
      name: 'Switch',
      color: Color(0xFF2563EB), // Blue
      boxRect: Rect.fromLTWH(0.28, 0.21, 0.14, 0.14),
      badgeOffset: Offset(0.35, 0.11),
      whatIsIt: 'A mechanical control device that opens or closes the electrical circuit.',
      whyUsed: 'Allows you to safely turn the circuit ON or OFF without disconnecting wires.',
      connectionInfo: 'Placed in series between the positive terminal of the 9V Battery and Resistor (R1).',
      examNotes: '• Open switch = Infinite resistance (No current flows).\n• Closed switch = Zero resistance (Current flows).',
      analogy: 'Like a drawbridge on a road—when lifted up (open), cars (electrons) cannot cross.',
    ),
    DiagramComponent(
      id: 'resistor',
      name: 'Resistor (R1)',
      color: Color(0xFF10B981), // Green
      boxRect: Rect.fromLTWH(0.45, 0.21, 0.15, 0.14),
      badgeOffset: Offset(0.525, 0.11),
      whatIsIt: 'A passive two-terminal component (220 Ω) that opposes electrical current.',
      whyUsed: 'Limits the current flowing through the circuit so delicate parts like the LED do not burn out.',
      connectionInfo: 'Connected in series between the Switch and the Anode (+) of the LED.',
      examNotes: '• Formula: V = I × R (Ohm\'s Law).\n• Unit: Ohms (Ω).\n• Drops excess voltage safely as heat.',
      analogy: 'Like a narrow pinch in a garden hose that slows down the water flow so the nozzle doesn\'t burst.',
    ),
    DiagramComponent(
      id: 'led',
      name: 'LED',
      color: Color(0xFF8B5CF6), // Purple
      boxRect: Rect.fromLTWH(0.66, 0.39, 0.13, 0.23),
      badgeOffset: Offset(0.85, 0.49),
      whatIsIt: 'Light Emitting Diode—a semiconductor light source that glows when current passes through it.',
      whyUsed: 'Acts as an indicator or light output; only allows current to flow in one direction.',
      connectionInfo: 'Connected in series after Resistor R1, returning back to the negative (-) terminal of the Battery.',
      examNotes: '• Forward biased to glow.\n• Anode (+) is longer leg; Cathode (-) is shorter leg.\n• Arrows pointing out indicate light emission.',
      analogy: 'Like a tiny one-way waterwheel that lights up a windmill whenever water flows through it in the right direction.',
    ),
  ];

  // Biology Cell Components Data (To showcase 2D Biology diagrams from problem statement)
  final List<DiagramComponent> _bioComponents = const [
    DiagramComponent(
      id: 'nucleus',
      name: 'Nucleus',
      color: Color(0xFF8B5CF6), // Purple
      boxRect: Rect.fromLTWH(0.28, 0.32, 0.18, 0.28),
      badgeOffset: Offset(0.14, 0.28),
      whatIsIt: 'The membrane-bound organelle that contains the cell\'s genetic material (DNA).',
      whyUsed: 'Controls and regulates cell activities such as growth, metabolism, and protein synthesis.',
      connectionInfo: 'Surrounded by the cytoplasm and connected directly to the endoplasmic reticulum.',
      examNotes: '• Known as the "Brain of the Cell".\n• Contains chromosomes made of DNA.\n• Enclosed by a double nuclear membrane.',
      analogy: 'Think of the nucleus as the Principal\'s office in a school—it holds all the blueprints and sends out instructions.',
    ),
    DiagramComponent(
      id: 'mitochondria',
      name: 'Mitochondria',
      color: Color(0xFFEF4444), // Red
      boxRect: Rect.fromLTWH(0.55, 0.25, 0.16, 0.18),
      badgeOffset: Offset(0.82, 0.28),
      whatIsIt:
          'Double-membrane organelle responsible for cellular respiration.',
      whyUsed: 'Generates most of the chemical energy (ATP) needed to power the cell\'s biochemical reactions.',
      connectionInfo: 'Suspended freely within the cytosol near high-energy demand areas like the nucleus.',
      examNotes: '• Known as the "Powerhouse of the Cell".\n• Produces energy in the form of ATP.\n• Has its own DNA and ribosomes.',
      analogy: 'Like a power plant or battery pack inside a city that converts fuel into usable electricity.',
    ),
    DiagramComponent(
      id: 'chloroplast',
      name: 'Chloroplast',
      color: Color(0xFF10B981), // Green
      boxRect: Rect.fromLTWH(0.52, 0.56, 0.17, 0.18),
      badgeOffset: Offset(0.82, 0.65),
      whatIsIt: 'Plant cell organelle containing green chlorophyll pigment.',
      whyUsed: 'Captures sunlight energy to convert water and carbon dioxide into glucose (Photosynthesis).',
      connectionInfo: 'Located within the cytoplasm of plant cells, working alongside mitochondria.',
      examNotes: '• Site of Photosynthesis.\n• Contains Chlorophyll (gives green color).\n• Present only in plant cells and algae.',
      analogy: 'Like solar panels on a house roof that turn sunlight into food and energy.',
    ),
    DiagramComponent(
      id: 'vacuole',
      name: 'Vacuole',
      color: Color(0xFF2563EB), // Blue
      boxRect: Rect.fromLTWH(0.28, 0.63, 0.19, 0.20),
      badgeOffset: Offset(0.14, 0.73),
      whatIsIt: 'A large membrane-bound fluid sac inside the cell.',
      whyUsed: 'Stores water, nutrients, and waste products while maintaining turgor pressure to keep the plant upright.',
      connectionInfo: 'Occupies central space in the cytoplasm, pushing other organelles toward the cell wall.',
      examNotes: '• Maintains cell rigidity (turgor pressure).\n• Surrounded by a membrane called Tonoplast.\n• Very large in plant cells.',
      analogy: 'Like a water storage tank that keeps a water balloon firm and stores supplies.',
    ),
  ];

  List<DiagramComponent> get _currentComponents =>
      _selectedDiagramIndex == 0 ? _circuitComponents : _bioComponents;

  void _toggleComponent(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
    });
  }

  void _switchDiagram(int index) {
    setState(() {
      _selectedDiagramIndex = index;
      _isProcessing = true;
      if (index == 0) {
        _selectedIds = {'resistor', 'led'};
      } else {
        _selectedIds = {'chloroplast', 'mitochondria'};
      }
    });
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    });
  }

  void _simulateReanalyze() {
    setState(() => _isProcessing = true);
    Future.delayed(const Duration(milliseconds: 700), () {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildTopHeader(),
          const Divider(height: 1, color: Color(0xFF1E293B)),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth > 1050) {
                  // Full 3-column Desktop/Web layout matching screenshot
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(width: 220, child: _buildLeftSidebar()),
                      const VerticalDivider(width: 1, color: Color(0xFF1E293B)),
                      Expanded(
                        flex: 6,
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(20),
                          child: _buildCenterContent(),
                        ),
                      ),
                      const VerticalDivider(width: 1, color: Color(0xFF1E293B)),
                      Expanded(
                        flex: 4,
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(20),
                          child: _buildRightExplanationPanel(),
                        ),
                      ),
                    ],
                  );
                } else {
                  // Responsive Tablet/Mobile fallback
                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _buildCenterContent(),
                        const SizedBox(height: 20),
                        _buildRightExplanationPanel(),
                      ],
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  // --- 1. TOP BAR ---
  Widget _buildTopHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      color: const Color(0xFF0B1221),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF2563EB).withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.auto_awesome,
              color: Color(0xFF38BDF8),
              size: 28,
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: const TextSpan(
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  children: [
                    TextSpan(
                      text: 'Snap',
                      style: TextStyle(color: Colors.white),
                    ),
                    TextSpan(
                      text: 'Explain',
                      style: TextStyle(color: Color(0xFF38BDF8)),
                    ),
                  ],
                ),
              ),
              const Text(
                'Understand  •  Explore  •  Learn',
                style: TextStyle(color: Colors.white54, fontSize: 12),
              ),
            ],
          ),
          const Spacer(),
          // Demo switcher for Hackathon presentation
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white12),
            ),
            child: Row(
              children: [
                const Text(
                  'Demo Preset: ',
                  style: TextStyle(fontSize: 12, color: Colors.white60),
                ),
                ChoiceChip(
                  label: const Text(
                    'Circuit (Physics)',
                    style: TextStyle(fontSize: 12),
                  ),
                  selected: _selectedDiagramIndex == 0,
                  selectedColor: const Color(0xFF2563EB),
                  onSelected: (_) => _switchDiagram(0),
                ),
                const SizedBox(width: 6),
                ChoiceChip(
                  label: const Text(
                    'Plant Cell (Biology)',
                    style: TextStyle(fontSize: 12),
                  ),
                  selected: _selectedDiagramIndex == 1,
                  selectedColor: const Color(0xFF10B981),
                  onSelected: (_) => _switchDiagram(1),
                ),
              ],
            ),
          ),
          const SizedBox(width: 24),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "Don't just see the diagram,",
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
              Text(
                "understand it.",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(width: 10),
          const Icon(
            Icons.lightbulb_outline,
            color: Color(0xFF38BDF8),
            size: 26,
          ),
        ],
      ),
    );
  }

  // --- 2. LEFT SIDEBAR ---
  Widget _buildLeftSidebar() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sidebarItem(
            Icons.upload_file_outlined,
            'Upload',
            true,
            onTap: _simulateReanalyze,
          ),
          const SizedBox(height: 8),
          _sidebarItem(
            Icons.schema_outlined,
            'My Diagrams',
            false,
            onTap: () => _switchDiagram(_selectedDiagramIndex == 0 ? 1 : 0),
          ),
          const SizedBox(height: 8),
          _sidebarItem(
            Icons.settings_outlined,
            'Settings',
            false,
            onTap: () {},
          ),
          const SizedBox(height: 30),
          const Divider(color: Colors.white12),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Text(
              'AI PIPELINE DEMO',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Colors.white38,
              ),
            ),
          ),
          SwitchListTile(
            dense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 8),
            title: const Text(
              'Compare Blurry Sketch',
              style: TextStyle(fontSize: 12),
            ),
            subtitle: const Text(
              'Before AI cleanup',
              style: TextStyle(fontSize: 10, color: Colors.white54),
            ),
            value: _showRawSketch,
            activeColor: const Color(0xFF38BDF8),
            onChanged: (v) => setState(() => _showRawSketch = v),
          ),
          SwitchListTile(
            dense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 8),
            title: const Text(
              'Simulate Improper Diagram',
              style: TextStyle(fontSize: 12),
            ),
            subtitle: const Text(
              'Show AI fix alert',
              style: TextStyle(fontSize: 10, color: Colors.white54),
            ),
            value: _showImproperWarning,
            activeColor: Colors.amber,
            onChanged: (v) => setState(() => _showImproperWarning = v),
          ),
        ],
      ),
    );
  }

  Widget _sidebarItem(
    IconData icon,
    String title,
    bool isActive, {
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isActive
              ? const Color(0xFF1E3A5F).withOpacity(0.6)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: isActive
              ? Border.all(color: const Color(0xFF38BDF8).withOpacity(0.3))
              : null,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: isActive ? const Color(0xFF38BDF8) : Colors.white70,
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                color: isActive ? Colors.white : Colors.white70,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- 3. CENTER INTERACTIVE DIAGRAM & PROMPTS ---
  Widget _buildCenterContent() {
    return Column(
      children: [
        // Top Card: Diagram Viewer
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF131C2E),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFF263554)),
          ),
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // File Header
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _selectedDiagramIndex == 0 ? Icons.memory : Icons.biotech,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _selectedDiagramIndex == 0
                              ? 'circuit_diagram.jpg'
                              : 'plant_cell_sketch.pdf',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Icon(
                              _showImproperWarning
                                  ? Icons.warning_amber_rounded
                                  : Icons.check_circle_outline,
                              color: _showImproperWarning
                                  ? Colors.amber
                                  : const Color(0xFF10B981),
                              size: 15,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              _showImproperWarning
                                  ? 'Improper diagram detected — AI auto-corrected missing resistor'
                                  : 'Diagram processed & enhanced from handwriting successfully',
                              style: TextStyle(
                                color: _showImproperWarning
                                    ? Colors.amber
                                    : const Color(0xFF10B981),
                                fontSize: 12.5,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: _simulateReanalyze,
                    icon: const Icon(
                      Icons.refresh,
                      size: 16,
                      color: Colors.white70,
                    ),
                    label: const Text(
                      'Re-analyze',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF334155)),
                      backgroundColor: const Color(0xFF1E293B),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
              if (_showImproperWarning) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.amber.withOpacity(0.4)),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.auto_fix_high,
                        color: Colors.amber,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'Validation Check: Your uploaded sketch connected a 9V battery directly to an LED (burnout risk!). SnapExplain suggested & inserted a 220Ω current-limiting resistor.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.amberAccent,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () =>
                            setState(() => _showImproperWarning = false),
                        child: const Text(
                          'Accept Proper Diagram',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 16),

              // INTERACTIVE WHITE CANVAS WITH CLICKABLE LABELS
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: _isProcessing
                      ? const Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircularProgressIndicator(
                                color: Color(0xFF2563EB),
                              ),
                              SizedBox(height: 12),
                              Text(
                                'Cleaning blurry sketch & detecting labels...',
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        )
                      : LayoutBuilder(
                          builder: (context, box) {
                            final w = box.maxWidth;
                            final h = box.maxHeight;
                            return Stack(
                              children: [
                                // Base 2D Diagram Painter
                                Positioned.fill(
                                  child: CustomPaint(
                                    painter: _selectedDiagramIndex == 0
                                        ? CircuitDiagramPainter(
                                            components: _currentComponents,
                                            selectedIds: _selectedIds,
                                            isRawSketch: _showRawSketch,
                                          )
                                        : BioDiagramPainter(
                                            components: _currentComponents,
                                            selectedIds: _selectedIds,
                                            isRawSketch: _showRawSketch,
                                          ),
                                  ),
                                ),

                                // Clickable Component Bounding Boxes
                                ..._currentComponents.map((comp) {
                                  final isSelected = _selectedIds.contains(
                                    comp.id,
                                  );
                                  return Positioned(
                                    left: comp.boxRect.left * w,
                                    top: comp.boxRect.top * h,
                                    width: comp.boxRect.width * w,
                                    height: comp.boxRect.height * h,
                                    child: GestureDetector(
                                      onTap: () => _toggleComponent(comp.id),
                                      child: MouseRegion(
                                        cursor: SystemMouseCursors.click,
                                        child: AnimatedContainer(
                                          duration: const Duration(
                                            milliseconds: 180,
                                          ),
                                          decoration: BoxDecoration(
                                            color: comp.color.withOpacity(
                                              isSelected ? 0.16 : 0.05,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                            border: Border.all(
                                              color: comp.color.withOpacity(
                                                isSelected ? 0.95 : 0.4,
                                              ),
                                              width: isSelected ? 2.5 : 1.5,
                                            ),
                                            boxShadow: isSelected
                                                ? [
                                                    BoxShadow(
                                                      color: comp.color
                                                          .withOpacity(0.28),
                                                      blurRadius: 10,
                                                      spreadRadius: 1,
                                                    ),
                                                  ]
                                                : [],
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }),

                                // Clickable Floating Color Badges
                                ..._currentComponents.map((comp) {
                                  final isSelected = _selectedIds.contains(
                                    comp.id,
                                  );
                                  return Positioned(
                                    left: comp.badgeOffset.dx * w - 48,
                                    top: comp.badgeOffset.dy * h - 16,
                                    child: GestureDetector(
                                      onTap: () => _toggleComponent(comp.id),
                                      child: MouseRegion(
                                        cursor: SystemMouseCursors.click,
                                        child: AnimatedContainer(
                                          duration: const Duration(
                                            milliseconds: 180,
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: isSelected
                                                ? comp.color
                                                : comp.color.withOpacity(0.75),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            border: Border.all(
                                              color: isSelected
                                                  ? Colors.white
                                                  : Colors.transparent,
                                              width: 1.5,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: comp.color.withOpacity(
                                                  0.4,
                                                ),
                                                blurRadius: 6,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              if (isSelected) ...[
                                                const Icon(
                                                  Icons.check,
                                                  size: 13,
                                                  color: Colors.white,
                                                ),
                                                const SizedBox(width: 4),
                                              ],
                                              Text(
                                                comp.name,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12.5,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                              ],
                            );
                          },
                        ),
                ),
              ),
              const SizedBox(height: 16),

              // Selected Components Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Selected components (click labels on diagram to toggle):',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  TextButton.icon(
                    onPressed: () => setState(() => _selectedIds.clear()),
                    icon: const Icon(
                      Icons.delete_outline,
                      size: 16,
                      color: Colors.white60,
                    ),
                    label: const Text(
                      'Clear selection',
                      style: TextStyle(color: Colors.white60, fontSize: 12.5),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 10,
                runSpacing: 8,
                children: _selectedIds.isEmpty
                    ? [
                        const Text(
                          'No labels selected. Click any colored label inside the diagram above!',
                          style: TextStyle(
                            color: Colors.amberAccent,
                            fontSize: 13,
                          ),
                        ),
                      ]
                    : _currentComponents
                          .where((c) => _selectedIds.contains(c.id))
                          .map(
                            (comp) => Chip(
                              backgroundColor: comp.color,
                              avatar: const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 16,
                              ),
                              label: Text(
                                comp.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              deleteIcon: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 16,
                              ),
                              onDeleted: () => _toggleComponent(comp.id),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              side: BorderSide.none,
                            ),
                          )
                          .toList(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Bottom Card: What would you like to know?
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF131C2E),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFF263554)),
          ),
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.help_outline, color: Color(0xFF38BDF8), size: 20),
                  SizedBox(width: 8),
                  Text(
                    'What would you like to know?',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: _prompts.map((prompt) {
                  final isSelected = _selectedPromptId == prompt.id;
                  return InkWell(
                    onTap: () => setState(() => _selectedPromptId = prompt.id),
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      width: 235,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF1E3A8A).withOpacity(0.45)
                            : const Color(0xFF0F172A),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF3B82F6)
                              : const Color(0xFF1E293B),
                          width: isSelected ? 1.8 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            prompt.icon,
                            color: isSelected
                                ? const Color(0xFF60A5FA)
                                : Colors.white54,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  prompt.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  prompt.subtitle,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isSelected
                                        ? const Color(0xFF93C5FD)
                                        : Colors.white54,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  onPressed: _simulateReanalyze,
                  icon: const Icon(
                    Icons.auto_awesome,
                    size: 16,
                    color: Colors.white,
                  ),
                  label: const Text(
                    'Explain  →',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 22,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --- 4. RIGHT EXPLANATION PANEL (Dynamic based on selected labels) ---
  Widget _buildRightExplanationPanel() {
    final selectedComps = _currentComponents
        .where((c) => _selectedIds.contains(c.id))
        .toList();
    final unselectedComps = _currentComponents
        .where((c) => !_selectedIds.contains(c.id))
        .toList();

    String headline;
    if (selectedComps.isEmpty) {
      headline = 'Select any label on the diagram to start learning!';
    } else if (selectedComps.length == 1) {
      final name = selectedComps.first.name;
      headline = _selectedPromptId == 'what'
          ? 'What is the $name?'
          : _selectedPromptId == 'why'
          ? 'Why is the $name used?'
          : 'Understanding the $name';
    } else {
      final names = selectedComps.map((e) => e.name).join(' and ');
      headline = 'How do the $names work together?';
    }

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF131C2E),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF263554)),
      ),
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.stars_rounded, color: Color(0xFF38BDF8), size: 22),
              SizedBox(width: 8),
              Text(
                'Explanation',
                style: TextStyle(
                  color: Color(0xFF38BDF8),
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            headline,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 20),

          if (selectedComps.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Text(
                '👆 Click on one or more colored labels (e.g., Resistor, LED, Battery) inside the diagram to get a beginner-friendly explanation tailored only to your doubt—without irrelevant fluff!',
                style: TextStyle(color: Colors.white70, height: 1.5),
              ),
            )
          else ...[
            // Step 1: Simple Answer
            _buildStepItem(
              number: '1',
              badgeColor: const Color(0xFF2563EB),
              title: 'Simple answer',
              titleColor: Colors.white,
              content: _buildSimpleAnswerText(selectedComps),
            ),
            const SizedBox(height: 18),

            // Step 2: How it works / Purpose
            _buildStepItem(
              number: '2',
              badgeColor: const Color(0xFF10B981),
              title: _selectedPromptId == 'exam'
                  ? 'Quick Exam Revision Notes'
                  : 'How it works',
              titleColor: const Color(0xFF10B981),
              content: _buildHowItWorksText(selectedComps),
            ),
            const SizedBox(height: 18),

            // Step 3: Connection in the diagram
            _buildStepItem(
              number: '3',
              badgeColor: const Color(0xFF8B5CF6),
              title: 'Connection in the diagram',
              titleColor: const Color(0xFFA78BFA),
              content: selectedComps
                  .map((c) => '• ${c.name}: ${c.connectionInfo}')
                  .join('\n\n'),
            ),
            const SizedBox(height: 18),

            // Step 4: Simple Analogy
            _buildStepItem(
              number: '4',
              badgeColor: const Color(0xFFF59E0B),
              title: 'Simple analogy',
              titleColor: Colors.white,
              content: _buildAnalogyText(selectedComps),
            ),
          ],

          const SizedBox(height: 24),

          // Bottom suggestion box
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF0F2442),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFF1D4ED8)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.lightbulb_outline,
                  color: Color(0xFF38BDF8),
                  size: 22,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Want to explore more?',
                        style: TextStyle(
                          color: Color(0xFF38BDF8),
                          fontWeight: FontWeight.bold,
                          fontSize: 13.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        unselectedComps.isNotEmpty
                            ? 'Try selecting the ${unselectedComps.map((e) => e.name).join(' or ')} to learn how they work in this diagram.'
                            : 'You have selected all components! Try switching the question card on the bottom left for Exam Notes.',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12.5,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _buildSimpleAnswerText(List<DiagramComponent> selected) {
    final ids = selected.map((e) => e.id).toSet();
    if (ids.contains('resistor') && ids.contains('led') && ids.length == 2) {
      return 'The resistor limits the current flowing through the LED. This prevents too much current from passing, which could damage the LED. So, they work together to make sure the LED gets the right amount of current.';
    }
    return selected.map((c) => '${c.name}: ${c.whatIsIt}').join('\n\n');
  }

  String _buildHowItWorksText(List<DiagramComponent> selected) {
    if (_selectedPromptId == 'exam') {
      return selected.map((c) => '${c.name}:\n${c.examNotes}').join('\n\n');
    }
    final ids = selected.map((e) => e.id).toSet();
    if (ids.contains('resistor') && ids.contains('led') && ids.length == 2) {
      return 'The battery provides 9V of voltage. The current flows through the switch, then the resistor, then the LED, and back to the battery.\n\nThe resistor drops some voltage and reduces the current. The LED then receives a safe current and emits light.';
    }
    return selected.map((c) => '${c.name}: ${c.whyUsed}').join('\n\n');
  }

  String _buildAnalogyText(List<DiagramComponent> selected) {
    final ids = selected.map((e) => e.id).toSet();
    if (ids.contains('resistor') && ids.contains('led') && ids.length == 2) {
      return 'Think of the resistor as a "current limiter" that protects the LED, just like a tap reduces water pressure to avoid overflowing a pipe.';
    }
    return selected.map((c) => c.analogy).join('\n\n');
  }

  Widget _buildStepItem({
    required String number,
    required Color badgeColor,
    required String title,
    required Color titleColor,
    required String content,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 26,
          height: 26,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: badgeColor, shape: BoxShape.circle),
          child: Text(
            number,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: titleColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 14.5,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                content,
                style: const TextStyle(
                  color: Color(0xFFCBD5E1),
                  fontSize: 13.5,
                  height: 1.48,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// --- CUSTOM PAINTER 1: ELECTRONIC CIRCUIT DIAGRAM ---
class CircuitDiagramPainter extends CustomPainter {
  final List<DiagramComponent> components;
  final Set<String> selectedIds;
  final bool isRawSketch;

  CircuitDiagramPainter({
    required this.components,
    required this.selectedIds,
    required this.isRawSketch,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final wirePaint = Paint()
      ..color = isRawSketch ? Colors.black54 : const Color(0xFF0F172A)
      ..strokeWidth = isRawSketch ? 2.0 : 3.2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Connector lines from badges to boxes
    for (final comp in components) {
      final linePaint = Paint()
        ..color = comp.color.withOpacity(0.7)
        ..strokeWidth = 1.8;
      final boxCenter = Offset(
        comp.boxRect.center.dx * w,
        comp.boxRect.center.dy * h,
      );
      final badgePos = Offset(comp.badgeOffset.dx * w, comp.badgeOffset.dy * h);
      canvas.drawLine(badgePos, boxCenter, linePaint);
    }

    // 1. Main circuit rectangular loop segments
    // Left vertical wire (above and below battery)
    canvas.drawLine(
      Offset(w * 0.255, h * 0.28),
      Offset(w * 0.255, h * 0.47),
      wirePaint,
    );
    canvas.drawLine(
      Offset(w * 0.255, h * 0.58),
      Offset(w * 0.255, h * 0.78),
      wirePaint,
    );

    // Top horizontal wires
    canvas.drawLine(
      Offset(w * 0.255, h * 0.28),
      Offset(w * 0.31, h * 0.28),
      wirePaint,
    );
    canvas.drawLine(
      Offset(w * 0.39, h * 0.28),
      Offset(w * 0.47, h * 0.28),
      wirePaint,
    );
    canvas.drawLine(
      Offset(w * 0.58, h * 0.28),
      Offset(w * 0.725, h * 0.28),
      wirePaint,
    );

    // Right vertical wires (above and below LED)
    canvas.drawLine(
      Offset(w * 0.725, h * 0.28),
      Offset(w * 0.725, h * 0.45),
      wirePaint,
    );
    canvas.drawLine(
      Offset(w * 0.725, h * 0.56),
      Offset(w * 0.725, h * 0.78),
      wirePaint,
    );

    // Bottom return wire
    canvas.drawLine(
      Offset(w * 0.255, h * 0.78),
      Offset(w * 0.725, h * 0.78),
      wirePaint,
    );

    // 2. Draw Battery Plates
    canvas.drawLine(
      Offset(w * 0.23, h * 0.47),
      Offset(w * 0.28, h * 0.47),
      wirePaint..strokeWidth = 3.5,
    );
    canvas.drawLine(
      Offset(w * 0.242, h * 0.51),
      Offset(w * 0.268, h * 0.51),
      wirePaint..strokeWidth = 5.5,
    );
    canvas.drawLine(
      Offset(w * 0.23, h * 0.545),
      Offset(w * 0.28, h * 0.545),
      wirePaint..strokeWidth = 3.5,
    );
    canvas.drawLine(
      Offset(w * 0.242, h * 0.58),
      Offset(w * 0.268, h * 0.58),
      wirePaint..strokeWidth = 5.5,
    );

    _drawText(canvas, '+', Offset(w * 0.215, h * 0.42), 18, FontWeight.bold);
    _drawText(canvas, '−', Offset(w * 0.215, h * 0.60), 18, FontWeight.bold);
    _drawText(canvas, '9 V', Offset(w * 0.145, h * 0.51), 16, FontWeight.w600);

    // 3. Draw Switch
    final circlePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawLine(
      Offset(w * 0.315, h * 0.28),
      Offset(w * 0.38, h * 0.235),
      wirePaint..strokeWidth = 3.2,
    );
    canvas.drawCircle(Offset(w * 0.315, h * 0.28), 5.5, circlePaint);
    canvas.drawCircle(Offset(w * 0.315, h * 0.28), 5.5, wirePaint);
    canvas.drawCircle(Offset(w * 0.385, h * 0.28), 5.5, circlePaint);
    canvas.drawCircle(Offset(w * 0.385, h * 0.28), 5.5, wirePaint);

    // 4. Draw Resistor Zig-Zag
    final resistorPath = Path()
      ..moveTo(w * 0.47, h * 0.28)
      ..lineTo(w * 0.485, h * 0.24)
      ..lineTo(w * 0.502, h * 0.32)
      ..lineTo(w * 0.518, h * 0.24)
      ..lineTo(w * 0.535, h * 0.32)
      ..lineTo(w * 0.552, h * 0.24)
      ..lineTo(w * 0.568, h * 0.32)
      ..lineTo(w * 0.58, h * 0.28);
    canvas.drawPath(resistorPath, wirePaint);
    _drawText(canvas, '220 Ω', Offset(w * 0.49, h * 0.37), 16, FontWeight.w600);

    // 5. Draw LED Symbol
    final ledPath = Path()
      ..moveTo(w * 0.70, h * 0.45)
      ..lineTo(w * 0.75, h * 0.45)
      ..lineTo(w * 0.725, h * 0.55)
      ..close();
    canvas.drawPath(ledPath, wirePaint);
    canvas.drawLine(
      Offset(w * 0.70, h * 0.555),
      Offset(w * 0.75, h * 0.555),
      wirePaint,
    );

    // LED light arrows
    canvas.drawLine(
      Offset(w * 0.755, h * 0.48),
      Offset(w * 0.775, h * 0.45),
      wirePaint..strokeWidth = 2.2,
    );
    canvas.drawLine(
      Offset(w * 0.76, h * 0.52),
      Offset(w * 0.78, h * 0.49),
      wirePaint..strokeWidth = 2.2,
    );
  }

  void _drawText(
    Canvas canvas,
    String text,
    Offset pos,
    double fontSize,
    FontWeight weight,
  ) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: const Color(0xFF0F172A),
          fontSize: fontSize,
          fontWeight: weight,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, pos);
  }

  @override
  bool shouldRepaint(covariant CircuitDiagramPainter oldDelegate) => true;
}

// --- CUSTOM PAINTER 2: 2D PLANT CELL BIOLOGY DIAGRAM ---
class BioDiagramPainter extends CustomPainter {
  final List<DiagramComponent> components;
  final Set<String> selectedIds;
  final bool isRawSketch;

  BioDiagramPainter({
    required this.components,
    required this.selectedIds,
    required this.isRawSketch,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Connector lines from badges to boxes
    for (final comp in components) {
      final linePaint = Paint()
        ..color = comp.color.withOpacity(0.7)
        ..strokeWidth = 1.8;
      final boxCenter = Offset(
        comp.boxRect.center.dx * w,
        comp.boxRect.center.dy * h,
      );
      final badgePos = Offset(comp.badgeOffset.dx * w, comp.badgeOffset.dy * h);
      canvas.drawLine(badgePos, boxCenter, linePaint);
    }

    // Outer Cell Wall
    final wallPaint = Paint()
      ..color = const Color(0xFF10B981).withOpacity(0.15)
      ..style = PaintingStyle.fill;
    final wallBorder = Paint()
      ..color = const Color(0xFF047857)
      ..strokeWidth = isRawSketch ? 2.0 : 4.0
      ..style = PaintingStyle.stroke;

    final cellRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.24, h * 0.14, w * 0.52, h * 0.74),
      const Radius.circular(36),
    );
    canvas.drawRRect(cellRect, wallPaint);
    canvas.drawRRect(cellRect, wallBorder);

    // Nucleus (Purple circle)
    canvas.drawCircle(
      Offset(w * 0.37, h * 0.46),
      h * 0.11,
      Paint()..color = const Color(0xFF8B5CF6).withOpacity(0.35),
    );
    canvas.drawCircle(
      Offset(w * 0.37, h * 0.46),
      h * 0.04,
      Paint()..color = const Color(0xFF6D28D9),
    );

    // Mitochondria (Red oval)
    final mitoRect = Rect.fromCenter(
      center: Offset(w * 0.63, h * 0.34),
      width: w * 0.12,
      height: h * 0.11,
    );
    canvas.drawOval(
      mitoRect,
      Paint()..color = const Color(0xFFEF4444).withOpacity(0.4),
    );
    canvas.drawOval(
      mitoRect,
      Paint()
        ..color = const Color(0xFFB91C1C)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );

    // Chloroplast (Green oval with stacks)
    final chloroRect = Rect.fromCenter(
      center: Offset(w * 0.605, h * 0.65),
      width: w * 0.13,
      height: h * 0.11,
    );
    canvas.drawOval(
      chloroRect,
      Paint()..color = const Color(0xFF10B981).withOpacity(0.45),
    );
    canvas.drawOval(
      chloroRect,
      Paint()
        ..color = const Color(0xFF047857)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );

    // Vacuole (Blue sac)
    final vacRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(w * 0.375, h * 0.73),
        width: w * 0.15,
        height: h * 0.14,
      ),
      const Radius.circular(20),
    );
    canvas.drawRRect(
      vacRect,
      Paint()..color = const Color(0xFF3B82F6).withOpacity(0.35),
    );
    canvas.drawRRect(
      vacRect,
      Paint()
        ..color = const Color(0xFF1D4ED8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(covariant BioDiagramPainter oldDelegate) => true;
}
