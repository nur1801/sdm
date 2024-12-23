import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sdm/models/dosen/kegiatan_model.dart';
import 'package:sdm/page/dosen/detailkegiatan_nonjti_page.dart';
import 'package:sdm/services/dosen/api_kegiatan.dart';
import 'package:sdm/widget/dosen/custom_bottomappbar.dart';
import 'package:intl/intl.dart';
import 'package:sdm/widget/dosen/sort_option.dart';
import 'package:sdm/widget/dosen/custom_filter.dart';

class DaftarKegiatanNonJTIPage extends StatefulWidget {
  const DaftarKegiatanNonJTIPage({super.key});

  @override
  DaftarKegiatanNonJTIPageState createState() => DaftarKegiatanNonJTIPageState();
}

class DaftarKegiatanNonJTIPageState extends State<DaftarKegiatanNonJTIPage> {
  final TextEditingController _searchController = TextEditingController();
  final ApiKegiatan _apiKegiatan = ApiKegiatan();

  List<KegiatanModel> kegiatanList = [];
  List<KegiatanModel> filteredKegiatanList = [];
  SortOption selectedSortOption = SortOption.abjadAZ;
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadKegiatan();
    _searchController.addListener(_searchKegiatan);
  }

  Future<void> _loadKegiatan() async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });

      final data = await _apiKegiatan.getKegiatanNonJTIList();
      setState(() {
        kegiatanList = data;
        filteredKegiatanList = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  void _searchKegiatan() {
    setState(() {
      filteredKegiatanList = kegiatanList.where((kegiatan) {
        final searchLower = _searchController.text.toLowerCase();
        final titleLower = kegiatan.namaKegiatan.toLowerCase();
        return titleLower.contains(searchLower);
      }).toList();
    });
  }

  void _sortKegiatanList(SortOption? option) {
    setState(() {
      selectedSortOption = option ?? selectedSortOption;
      switch (selectedSortOption) {
        case SortOption.abjadAZ:
          filteredKegiatanList.sort((a, b) => a.namaKegiatan.compareTo(b.namaKegiatan));
          break;
        case SortOption.abjadZA:
          filteredKegiatanList.sort((a, b) => b.namaKegiatan.compareTo(a.namaKegiatan));
          break;
        case SortOption.tanggalTerdekat:
          filteredKegiatanList.sort((a, b) => DateFormat('dd-MM-yyyy').parse(a.tanggalMulai).compareTo(DateFormat('dd-MM-yyyy').parse(b.tanggalMulai)));
          break;
        case SortOption.tanggalTerjauh:
          filteredKegiatanList.sort((a, b) => DateFormat('dd-MM-yyyy').parse(b.tanggalMulai).compareTo(DateFormat('dd-MM-yyyy').parse(a.tanggalMulai)));
          break;
        default:
          break;
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'Daftar Kegiatan Non JTI',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: screenWidth * 0.05,
          ),
          textAlign: TextAlign.center,
        ),
        backgroundColor: const Color.fromARGB(255, 103, 119, 239),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          CustomFilter(
            controller: _searchController,
            onChanged: (value) => _searchKegiatan(),
            selectedSortOption: selectedSortOption,
            onSortOptionChanged: (option) => _sortKegiatanList(option),
            sortOptions: SortOption.values.where((option) => option != SortOption.poinTerbanyak && option != SortOption.poinTersedikit).toList(),
          ),
          const Divider(),
          const SizedBox(height: 10),
          Expanded(
            child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : error != null
                ? Center(child: Text(error!))
                : filteredKegiatanList.isEmpty
                  ? const Center(child: Text('Tidak ada kegiatan'))
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: filteredKegiatanList.map((kegiatan) {
                          return Column(
                            children: [
                              _buildKegiatanCard(
                                context,
                                kegiatan: kegiatan,
                                screenWidth: screenWidth,
                              ),
                              const SizedBox(height: 16),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
          ),
        ],
      ),
      floatingActionButton: const CustomBottomAppBar().buildFloatingActionButton(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: const CustomBottomAppBar(),
    );
  }

  Widget _buildKegiatanCard(
    BuildContext context, {
    required KegiatanModel kegiatan,
    required double screenWidth,
  }) {
    final fontSize = screenWidth < 500 ? 14.0 : 16.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Card
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: const BoxDecoration(
              color: Color.fromARGB(255, 5, 167, 170),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  kegiatan.namaKegiatan,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: fontSize,
                  ),
                ),
              ],
            ),
          ),
          // Isi Card
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Jabatan',
                          style: GoogleFonts.poppins(
                            fontSize: fontSize,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          kegiatan.jabatanNama ?? '-',
                          style: GoogleFonts.poppins(
                            fontSize: fontSize,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Tanggal Mulai',
                          style: GoogleFonts.poppins(
                            fontSize: fontSize,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          kegiatan.tanggalMulai,
                          style: GoogleFonts.poppins(
                            fontSize: fontSize,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Tanggal Acara',
                          style: GoogleFonts.poppins(
                            fontSize: fontSize,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          kegiatan.tanggalAcara,
                          style: GoogleFonts.poppins(
                            fontSize: fontSize,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Tanggal Selesai',
                          style: GoogleFonts.poppins(
                            fontSize: fontSize,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          kegiatan.tanggalSelesai,
                          style: GoogleFonts.poppins(
                            fontSize: fontSize,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Divider(), // Garis pembatas
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailKegiatanNonJTIPage(
                            idKegiatan: kegiatan.idKegiatan,
                          ),
                        ),
                      );
                    },
                    child: Text(
                      'Lihat Detail',
                      style: GoogleFonts.poppins(
                        color: const Color(0xFF00796B),
                        fontSize: fontSize,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}