///
/// Generated file. Do not edit.
///
// coverage:ignore-file
// ignore_for_file: type=lint, unused_import
// dart format off

import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:slang/generated.dart';
import 'strings.g.dart';

// Path: <root>
class TranslationsId extends Translations with BaseTranslations<AppLocale, Translations> {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	TranslationsId({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<AppLocale, Translations>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  _meta = meta ?? TranslationMetadata(
		    locale: AppLocale.id,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		_meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <id>.
	final TranslationMetadata<AppLocale, Translations> _meta;
	@override TranslationMetadata<AppLocale, Translations> get $meta => _meta;

	/// Access flat map
	@override dynamic operator[](String key) => _meta.getTranslation(key) ?? super[key];

	late final TranslationsId _root = this; // ignore: unused_field

	@override 
	TranslationsId $copyWith({TranslationMetadata<AppLocale, Translations>? meta}) => TranslationsId(meta: meta ?? this.$meta);

	// Translations
	@override String get appName => 'Solaris Record';
	@override late final _Translations$nav$id nav = _Translations$nav$id._(_root);
	@override late final _Translations$pools$id pools = _Translations$pools$id._(_root);
	@override late final _Translations$stats$id stats = _Translations$stats$id._(_root);
	@override late final _Translations$import$id import = _Translations$import$id._(_root);
	@override late final _Translations$accounts$id accounts = _Translations$accounts$id._(_root);
	@override late final _Translations$settings$id settings = _Translations$settings$id._(_root);
	@override late final _Translations$appearance$id appearance = _Translations$appearance$id._(_root);
	@override late final _Translations$language$id language = _Translations$language$id._(_root);
	@override late final _Translations$data$id data = _Translations$data$id._(_root);
	@override late final _Translations$about$id about = _Translations$about$id._(_root);
	@override late final _Translations$info$id info = _Translations$info$id._(_root);
}

// Path: nav
class _Translations$nav$id extends Translations$nav$en {
	_Translations$nav$id._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get stats => 'Convene';
	@override String get settings => 'Pengaturan';
	@override String get overview => 'Ringkasan';
}

// Path: pools
class _Translations$pools$id extends Translations$pools$en {
	_Translations$pools$id._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get featuredResonator => 'Resonator Unggulan';
	@override String get featuredWeapon => 'Senjata Unggulan';
	@override String get standardResonator => 'Resonator Standar';
	@override String get standardWeapon => 'Senjata Standar';
	@override String get beginner => 'Pemula';
	@override String get beginnerChoice => 'Pilihan Pemula';
	@override String get newVoyageResonator => 'Resonator New Voyage';
	@override String get newVoyageWeapon => 'Senjata New Voyage';
	@override String get collabResonator => 'Resonator Kolaborasi';
	@override String get collabWeapon => 'Senjata Kolaborasi';
	@override String get reverbResonator => 'Resonator Reverb';
	@override String get reverbWeapon => 'Senjata Reverb';
}

// Path: stats
class _Translations$stats$id extends Translations$stats$en {
	_Translations$stats$id._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get noAccountTitle => 'Belum ada akun';
	@override String get noAccountBody => 'Impor URL riwayat convene untuk memulai.';
	@override String get goToImport => 'Impor record';
	@override String get noPulls => 'Belum ada pull di pool ini.';
	@override String get fiveStarPity => 'Pity 5★';
	@override String get fourStarPity => 'Pity 4★';
	@override String pullsUntilHard({required Object n}) => '${n} pull lagi hingga dijamin';
	@override String get total => 'Total pull';
	@override String get fiveStars => '5★';
	@override String get fourStars => '4★';
	@override String get threeStars => '3★';
	@override String get average => 'Rata-rata pull per 5★';
	@override String get averageNone => '–';
	@override String get fiftyFifty => '50/50';
	@override String fiftyFiftyRecord({required Object won, required Object lost}) => '${won} menang · ${lost} kalah';
	@override String get nextGuaranteed => '5★ berikutnya dijamin unggulan';
	@override String get fiveStarTimeline => 'Pull 5★';
	@override String get history => 'Riwayat';
	@override String pullsUsed({required Object n}) => '${n} pull';
	@override String get won => 'Menang 50/50';
	@override String get lost => 'Kalah 50/50';
	@override String get guaranteed => 'Dijamin';
	@override String get sectionPity => 'Pity';
	@override String get sectionOverview => 'Ringkasan';
	@override String get switchAccount => 'Ganti akun';
	@override String pullNumber({required Object n}) => '#${n}';
	@override String get filterAll => 'Semua';
	@override String get noMatches => 'Tidak ada record yang cocok dengan filter ini.';
	@override String get previousPage => 'Halaman sebelumnya';
	@override String get nextPage => 'Halaman berikutnya';
	@override String get pullsLabel => 'Pull';
	@override String get detailTime => 'Waktu';
	@override String get detailResult => 'Hasil';
	@override String get detailPity => 'Pull terpakai';
	@override String get legendTitle => 'Warna cincin';
	@override String get countFive => 'Jumlah 5★';
	@override String get countFour => 'Jumlah 4★';
	@override String ofTotal({required Object pct}) => '${pct}% dari total';
	@override String ofTotalAvg({required Object pct, required Object avg}) => '${pct}% dari total · Rata-rata ${avg} pull';
	@override String totalDetail({required Object n}) => '${n} 3★';
	@override String timelineTitle({required Object n}) => 'Linimasa 5★ (${n})';
	@override String get timelineNow => 'Sekarang';
	@override String get luckLucky => 'Beruntung';
	@override String get luckAverage => 'Sedang';
	@override String get luckUnlucky => 'Kurang beruntung';
	@override String avgPulls({required Object avg}) => 'Rata-rata ${avg} pull';
	@override String get searchHint => 'Cari berdasarkan nama';
	@override String get filter => 'Filter';
	@override String get filterTitle => 'Filter riwayat';
	@override String get filterRarity => 'Rarity';
	@override String get filterType => 'Jenis';
	@override String get filterSort => 'Urutan';
	@override String get sortNewest => 'Terbaru dulu';
	@override String get sortOldest => 'Terlama dulu';
	@override String get filterReset => 'Reset';
	@override String get filterApply => 'Terapkan';
	@override String results({required Object n}) => '${n} hasil';
	@override String get clearFilters => 'Hapus semua';
	@override String resultsOne({required Object n}) => '${n} hasil';
	@override String get rowsPerPage => 'Baris per halaman';
	@override String rangeOf({required Object from, required Object to, required Object total}) => '${from}–${to} dari ${total}';
	@override String get firstPage => 'Halaman pertama';
	@override String get lastPage => 'Halaman terakhir';
	@override String get poolTypes => 'Jenis pull';
	@override String get togglePoolTypes => 'Tampilkan atau sembunyikan jenis pull';
	@override String get overviewTitle => 'Ringkasan';
	@override String get overviewAll => 'Semua jenis pull';
	@override String get rarityDistribution => 'Distribusi rarity';
	@override String get typeDistribution => 'Distribusi jenis';
	@override String get pityPerType => 'Pity per jenis pull';
	@override String sinceLastFive({required Object n}) => '${n} pull sejak 5★ terakhir';
	@override String get noFiveYet => 'Belum ada 5★';
	@override String get noPullsAnywhere => 'Belum ada pull. Impor record untuk melihat ringkasan.';
	@override String get updateShort => 'Perbarui';
	@override String get manageAccounts => 'Kelola akun';
	@override String get sortFieldTime => 'Waktu';
	@override String get sortFieldName => 'Nama';
	@override String get sortFieldType => 'Tipe';
	@override String get sortFieldRarity => 'Rarity';
	@override String get sortFieldPity => 'Pity';
	@override String get sortDesc => 'Menurun';
	@override String get sortAsc => 'Menaik';
	@override String pityShort({required Object n}) => 'Pity ${n}';
	@override String get topRarityTitle => '5★ per tipe pull';
	@override String get timelineAllTitle => 'Timeline 5★ · semua tipe pull';
	@override String timelineNowAll({required Object n}) => '${n} pull sejak 5★ terakhir di semua tipe pull';
	@override String timelineLoadMore({required Object n}) => 'Tampilkan lagi (${n} lagi)';
	@override String get timelineVertical => 'Tampilan vertikal';
	@override String get timelineHorizontal => 'Tampilan horizontal';
}

// Path: import
class _Translations$import$id extends Translations$import$en {
	_Translations$import$id._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get title => 'Impor record convene';
	@override String get instructions => 'Buka Riwayat Convene di game, salin URL record, lalu tempel di sini.';
	@override String get urlLabel => 'URL riwayat convene';
	@override String get paste => 'Tempel';
	@override String get update => 'Perbarui record';
	@override String fetching({required Object pool}) => 'Mengambil ${pool}…';
	@override String done({required Object n, required Object uid}) => '${n} record baru diimpor untuk UID ${uid}.';
	@override String get errorInvalidUrl => 'Itu bukan URL riwayat convene.';
	@override String errorMissing({required Object params}) => 'URL tidak memiliki: ${params}.';
	@override String get errorExpired => 'URL ditolak atau sudah kedaluwarsa. Buka Riwayat Convene di game lagi dan salin URL baru.';
	@override String get errorRateLimited => 'Terlalu banyak permintaan. Tunggu sebentar lalu coba lagi.';
	@override String get errorNetwork => 'Kesalahan jaringan. Periksa koneksi lalu coba lagi.';
	@override String get errorUnexpected => 'Respons server tidak terduga.';
	@override String get stepsTitle => 'Cara mendapatkan URL';
	@override String get step1 => 'Buka Riwayat Convene di Wuthering Waves dan tunggu halaman termuat.';
	@override String get step2 => 'Salin URL riwayat convene. Isinya memuat svr_id, player_id, dan record_id.';
	@override String get step3 => 'Tempel di bawah lalu ketuk Perbarui record.';
	@override String get clear => 'Hapus';
	@override String get progressTitle => 'Progres';
	@override String get resultTitle => 'Hasil';
	@override String get viewRecords => 'Lihat record';
	@override String get retry => 'Coba lagi';
	@override String get close => 'Tutup';
	@override String get savedHint => 'Memakai tautan yang tersimpan dari update terakhir. Jika sudah kedaluwarsa, Anda akan diminta tautan baru.';
	@override String get fromFile => 'Impor dari file JSON';
}

// Path: accounts
class _Translations$accounts$id extends Translations$accounts$en {
	_Translations$accounts$id._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get title => 'Akun';
	@override String get empty => 'Belum ada akun. Impor URL convene untuk menambahkan.';
	@override String uid({required Object uid}) => 'UID ${uid}';
	@override String get active => 'Aktif';
	@override String get editAlias => 'Ubah alias';
	@override String get alias => 'Alias';
	@override String get delete => 'Hapus akun';
	@override String get deleteTitle => 'Hapus akun?';
	@override String deleteBody({required Object uid}) => 'Semua record UID ${uid} akan dihapus dari perangkat ini.';
	@override String get save => 'Simpan';
	@override String get cancel => 'Batal';
	@override String get emptyTitle => 'Belum ada akun';
	@override String get addAccount => 'Impor record';
	@override String get sectionAll => 'Akun Anda';
	@override String get switchTitle => 'Ganti akun';
	@override String get actions => 'Aksi';
	@override String get sectionPrivacy => 'Privasi';
	@override String get maskUid => 'Samarkan UID';
	@override String get maskUidSubtitle => 'Tampilkan hanya 3 digit pertama UID di seluruh aplikasi';
	@override String defaultName({required Object n}) => 'Akun ${n}';
}

// Path: settings
class _Translations$settings$id extends Translations$settings$en {
	_Translations$settings$id._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get title => 'Pengaturan';
	@override String get appearance => 'Tampilan';
	@override String get appearanceSubtitle => 'Tema dan warna';
	@override String get data => 'Data & penyimpanan';
	@override String get dataSubtitle => 'Cadangan, cache gambar dan record tersimpan';
	@override String get about => 'Tentang';
	@override String get aboutSubtitle => 'Versi, sumber, dan disclaimer';
	@override String get accounts => 'Akun';
	@override String get accountsSubtitle => 'UID dan alias';
	@override String get import => 'Impor record';
	@override String get importSubtitle => 'Perbarui dari URL riwayat convene';
}

// Path: appearance
class _Translations$appearance$id extends Translations$appearance$en {
	_Translations$appearance$id._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get title => 'Tampilan';
	@override String get sectionColor => 'Warna';
	@override String get dynamicColor => 'Warna dinamis';
	@override String get dynamicColorSubtitle => 'Gunakan warna dari wallpaper jika didukung platform';
	@override String get accent => 'Warna aksen';
	@override String get sectionTheme => 'Tema';
	@override String get themeSystem => 'Sistem';
	@override String get themeLight => 'Terang';
	@override String get themeDark => 'Gelap';
	@override String get amoled => 'Gelap AMOLED';
	@override String get amoledSubtitle => 'Latar hitam pekat pada mode gelap';
	@override String get sectionLanguage => 'Bahasa';
	@override String get language => 'Bahasa';
	@override String get dataLanguage => 'Bahasa data';
	@override String get dataLanguageDesc => 'Bahasa nama resonator dan senjata di record dan grafik Anda. Record yang tersimpan tidak diubah, dan item tanpa terjemahan tetap berbahasa Inggris.';
	@override String get dataLanguageDefault => 'English';
	@override String get dataLanguageDefaultSubtitle => 'Sesuai yang diambil dari game';
}

// Path: language
class _Translations$language$id extends Translations$language$en {
	_Translations$language$id._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get title => 'Bahasa';
	@override String get system => 'Default sistem';
	@override String get systemSubtitle => 'Ikuti bahasa perangkat';
}

// Path: data
class _Translations$data$id extends Translations$data$en {
	_Translations$data$id._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get title => 'Data & penyimpanan';
	@override String get sectionCache => 'Cache';
	@override String get clearImages => 'Hapus cache gambar';
	@override String get clearImagesSubtitle => 'Menghapus ikon item yang diunduh';
	@override String get imagesCleared => 'Cache gambar dihapus';
	@override String get sectionRecords => 'Record';
	@override String get deleteAll => 'Hapus semua data';
	@override String get deleteAllSubtitle => 'Menghapus semua akun dan record convene dari perangkat ini';
	@override String get deleteAllTitle => 'Hapus semua data?';
	@override String get deleteAllBody => 'Semua akun dan record akan dihapus permanen dari perangkat ini. Tindakan ini tidak bisa dibatalkan.';
	@override String get deleted => 'Semua data dihapus';
	@override String get cancel => 'Batal';
	@override String get confirm => 'Hapus';
	@override String get sectionUsage => 'Penyimpanan terpakai';
	@override String get total => 'Total';
	@override String get database => 'Database record';
	@override String databaseDetail({required Object records, required Object accounts}) => '${records} record · ${accounts} akun';
	@override String get imageCache => 'Cache gambar';
	@override String get calculating => 'Menghitung…';
	@override String get clearImagesTitle => 'Hapus cache gambar?';
	@override String get clearImagesBody => 'Ikon item yang diunduh akan dihapus dan diunduh lagi saat dibutuhkan.';
	@override String clearImagesBodySize({required Object size}) => 'Ikon item yang diunduh sebesar ${size} akan dihapus dan diunduh lagi saat dibutuhkan.';
	@override String get clear => 'Bersihkan';
	@override String get sectionBackup => 'Cadangan';
	@override String get export => 'Ekspor cadangan';
	@override String get exportSubtitle => 'Simpan semua akun dan record ke file JSON';
	@override String exportDone({required Object records}) => '${records} record diekspor';
	@override String get exportEmpty => 'Belum ada data untuk diekspor';
	@override String get exportFailed => 'Gagal menyimpan file cadangan';
	@override String get import => 'Impor dari file';
	@override String get importSubtitle => 'Pulihkan cadangan, atau impor ekspor WuWa Tracker';
	@override String importDone({required Object records, required Object accounts}) => '${records} record baru ditambahkan ke ${accounts} akun';
	@override String get importNothingNew => 'Tidak ada record baru di file ini';
	@override String get importForeign => 'Ini bukan cadangan Solaris Record maupun ekspor WuWa Tracker';
	@override String get importInvalid => 'File rusak atau formatnya tidak sesuai';
	@override String get importTooNew => 'Cadangan ini dibuat oleh versi aplikasi yang lebih baru';
	@override String get importFailed => 'Gagal mengimpor file';
	@override String get sectionLogs => 'Log debug';
	@override String get logsHint => 'Untuk laporan bug. UID dan tautan disamarkan.';
	@override String logsSize({required Object size}) => '${size} log · UID dan tautan disamarkan';
	@override String get exportLogs => 'Ekspor log';
	@override String get logsEmpty => 'Belum ada log';
	@override String get logsExported => 'Log diekspor';
	@override String get logsExportFailed => 'Gagal menyimpan file log';
	@override String get clearLogs => 'Hapus log';
	@override String get clearLogsTitle => 'Hapus log?';
	@override String get clearLogsBody => 'Semua log debug yang tersimpan akan dihapus. Ekspor dulu jika Anda memerlukannya untuk laporan bug.';
	@override String get logsCleared => 'Log dihapus';
}

// Path: about
class _Translations$about$id extends Translations$about$en {
	_Translations$about$id._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get title => 'Tentang';
	@override String version({required Object version}) => 'Versi ${version}';
	@override String get description => 'Lacak riwayat convene Wuthering Waves di banyak akun: pity, pool, dan statistik.';
	@override String get sectionInfo => 'Informasi';
	@override String get sourceTitle => 'Sumber data';
	@override String get sourceBody => 'Record diambil dari layanan riwayat convene game memakai URL yang Anda tempel. Ikon item berasal dari guide server Kuro dan encore.moe.';
	@override String get disclaimerTitle => 'Disclaimer';
	@override String get disclaimerBody => 'Solaris Record adalah proyek penggemar tidak resmi, tidak berafiliasi dengan atau didukung Kuro Games. Wuthering Waves dan asetnya milik Kuro Games.';
	@override String get licensesTitle => 'Lisensi open source';
	@override String get licensesBody => 'Solaris Record adalah open source dengan lisensi MIT. Lihat lisensi pustaka dan font yang dipakainya.';
}

// Path: info
class _Translations$info$id extends Translations$info$en {
	_Translations$info$id._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get title => 'Info item';
	@override String get button => 'Info item';
	@override String get resonator => 'Resonator';
	@override String get weapon => 'Senjata';
	@override String get element => 'Elemen';
	@override String get weaponType => 'Jenis senjata';
	@override String get introduction => 'Pengantar';
	@override String get baseStats => 'Statistik dasar (Lv. 1)';
	@override String get baseStatsAtLevel => 'Statistik dasar';
	@override String get level => 'Level';
	@override String get skills => 'Skill';
	@override String get effect => 'Efek senjata';
	@override String get tags => 'Tag';
	@override String get error => 'Gagal memuat info item. Periksa koneksi lalu coba lagi.';
	@override String get notFound => 'Info untuk item ini tidak tersedia.';
	@override String get source => 'Info dari encore.moe';
	@override String get close => 'Tutup';
	@override String get viewOnEncore => 'Lihat di encore.moe';
	@override String get openFailed => 'Tidak bisa membuka tautan.';
	@override String get galleryIcon => 'Ikon';
	@override String get galleryOutfit => 'Kostum';
	@override String get galleryConvene => 'Convene';
	@override String get galleryPrevious => 'Gambar sebelumnya';
	@override String get galleryNext => 'Gambar berikutnya';
	@override String get imageSave => 'Simpan gambar';
	@override String get imageRefetch => 'Ambil ulang gambar';
	@override String get imageZoomIn => 'Perbesar';
	@override String get imageZoomOut => 'Perkecil';
	@override String get imageSaved => 'Gambar disimpan';
	@override String get imageSaveFailed => 'Gagal menyimpan gambar';
	@override String get imageLoadFailed => 'Gagal memuat gambar';
}

/// The flat map containing all translations for locale <id>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on TranslationsId {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'appName' => 'Solaris Record',
			'nav.stats' => 'Convene',
			'nav.settings' => 'Pengaturan',
			'nav.overview' => 'Ringkasan',
			'pools.featuredResonator' => 'Resonator Unggulan',
			'pools.featuredWeapon' => 'Senjata Unggulan',
			'pools.standardResonator' => 'Resonator Standar',
			'pools.standardWeapon' => 'Senjata Standar',
			'pools.beginner' => 'Pemula',
			'pools.beginnerChoice' => 'Pilihan Pemula',
			'pools.newVoyageResonator' => 'Resonator New Voyage',
			'pools.newVoyageWeapon' => 'Senjata New Voyage',
			'pools.collabResonator' => 'Resonator Kolaborasi',
			'pools.collabWeapon' => 'Senjata Kolaborasi',
			'pools.reverbResonator' => 'Resonator Reverb',
			'pools.reverbWeapon' => 'Senjata Reverb',
			'stats.noAccountTitle' => 'Belum ada akun',
			'stats.noAccountBody' => 'Impor URL riwayat convene untuk memulai.',
			'stats.goToImport' => 'Impor record',
			'stats.noPulls' => 'Belum ada pull di pool ini.',
			'stats.fiveStarPity' => 'Pity 5★',
			'stats.fourStarPity' => 'Pity 4★',
			'stats.pullsUntilHard' => ({required Object n}) => '${n} pull lagi hingga dijamin',
			'stats.total' => 'Total pull',
			'stats.fiveStars' => '5★',
			'stats.fourStars' => '4★',
			'stats.threeStars' => '3★',
			'stats.average' => 'Rata-rata pull per 5★',
			'stats.averageNone' => '–',
			'stats.fiftyFifty' => '50/50',
			'stats.fiftyFiftyRecord' => ({required Object won, required Object lost}) => '${won} menang · ${lost} kalah',
			'stats.nextGuaranteed' => '5★ berikutnya dijamin unggulan',
			'stats.fiveStarTimeline' => 'Pull 5★',
			'stats.history' => 'Riwayat',
			'stats.pullsUsed' => ({required Object n}) => '${n} pull',
			'stats.won' => 'Menang 50/50',
			'stats.lost' => 'Kalah 50/50',
			'stats.guaranteed' => 'Dijamin',
			'stats.sectionPity' => 'Pity',
			'stats.sectionOverview' => 'Ringkasan',
			'stats.switchAccount' => 'Ganti akun',
			'stats.pullNumber' => ({required Object n}) => '#${n}',
			'stats.filterAll' => 'Semua',
			'stats.noMatches' => 'Tidak ada record yang cocok dengan filter ini.',
			'stats.previousPage' => 'Halaman sebelumnya',
			'stats.nextPage' => 'Halaman berikutnya',
			'stats.pullsLabel' => 'Pull',
			'stats.detailTime' => 'Waktu',
			'stats.detailResult' => 'Hasil',
			'stats.detailPity' => 'Pull terpakai',
			'stats.legendTitle' => 'Warna cincin',
			'stats.countFive' => 'Jumlah 5★',
			'stats.countFour' => 'Jumlah 4★',
			'stats.ofTotal' => ({required Object pct}) => '${pct}% dari total',
			'stats.ofTotalAvg' => ({required Object pct, required Object avg}) => '${pct}% dari total · Rata-rata ${avg} pull',
			'stats.totalDetail' => ({required Object n}) => '${n} 3★',
			'stats.timelineTitle' => ({required Object n}) => 'Linimasa 5★ (${n})',
			'stats.timelineNow' => 'Sekarang',
			'stats.luckLucky' => 'Beruntung',
			'stats.luckAverage' => 'Sedang',
			'stats.luckUnlucky' => 'Kurang beruntung',
			'stats.avgPulls' => ({required Object avg}) => 'Rata-rata ${avg} pull',
			'stats.searchHint' => 'Cari berdasarkan nama',
			'stats.filter' => 'Filter',
			'stats.filterTitle' => 'Filter riwayat',
			'stats.filterRarity' => 'Rarity',
			'stats.filterType' => 'Jenis',
			'stats.filterSort' => 'Urutan',
			'stats.sortNewest' => 'Terbaru dulu',
			'stats.sortOldest' => 'Terlama dulu',
			'stats.filterReset' => 'Reset',
			'stats.filterApply' => 'Terapkan',
			'stats.results' => ({required Object n}) => '${n} hasil',
			'stats.clearFilters' => 'Hapus semua',
			'stats.resultsOne' => ({required Object n}) => '${n} hasil',
			'stats.rowsPerPage' => 'Baris per halaman',
			'stats.rangeOf' => ({required Object from, required Object to, required Object total}) => '${from}–${to} dari ${total}',
			'stats.firstPage' => 'Halaman pertama',
			'stats.lastPage' => 'Halaman terakhir',
			'stats.poolTypes' => 'Jenis pull',
			'stats.togglePoolTypes' => 'Tampilkan atau sembunyikan jenis pull',
			'stats.overviewTitle' => 'Ringkasan',
			'stats.overviewAll' => 'Semua jenis pull',
			'stats.rarityDistribution' => 'Distribusi rarity',
			'stats.typeDistribution' => 'Distribusi jenis',
			'stats.pityPerType' => 'Pity per jenis pull',
			'stats.sinceLastFive' => ({required Object n}) => '${n} pull sejak 5★ terakhir',
			'stats.noFiveYet' => 'Belum ada 5★',
			'stats.noPullsAnywhere' => 'Belum ada pull. Impor record untuk melihat ringkasan.',
			'stats.updateShort' => 'Perbarui',
			'stats.manageAccounts' => 'Kelola akun',
			'stats.sortFieldTime' => 'Waktu',
			'stats.sortFieldName' => 'Nama',
			'stats.sortFieldType' => 'Tipe',
			'stats.sortFieldRarity' => 'Rarity',
			'stats.sortFieldPity' => 'Pity',
			'stats.sortDesc' => 'Menurun',
			'stats.sortAsc' => 'Menaik',
			'stats.pityShort' => ({required Object n}) => 'Pity ${n}',
			'stats.topRarityTitle' => '5★ per tipe pull',
			'stats.timelineAllTitle' => 'Timeline 5★ · semua tipe pull',
			'stats.timelineNowAll' => ({required Object n}) => '${n} pull sejak 5★ terakhir di semua tipe pull',
			'stats.timelineLoadMore' => ({required Object n}) => 'Tampilkan lagi (${n} lagi)',
			'stats.timelineVertical' => 'Tampilan vertikal',
			'stats.timelineHorizontal' => 'Tampilan horizontal',
			'import.title' => 'Impor record convene',
			'import.instructions' => 'Buka Riwayat Convene di game, salin URL record, lalu tempel di sini.',
			'import.urlLabel' => 'URL riwayat convene',
			'import.paste' => 'Tempel',
			'import.update' => 'Perbarui record',
			'import.fetching' => ({required Object pool}) => 'Mengambil ${pool}…',
			'import.done' => ({required Object n, required Object uid}) => '${n} record baru diimpor untuk UID ${uid}.',
			'import.errorInvalidUrl' => 'Itu bukan URL riwayat convene.',
			'import.errorMissing' => ({required Object params}) => 'URL tidak memiliki: ${params}.',
			'import.errorExpired' => 'URL ditolak atau sudah kedaluwarsa. Buka Riwayat Convene di game lagi dan salin URL baru.',
			'import.errorRateLimited' => 'Terlalu banyak permintaan. Tunggu sebentar lalu coba lagi.',
			'import.errorNetwork' => 'Kesalahan jaringan. Periksa koneksi lalu coba lagi.',
			'import.errorUnexpected' => 'Respons server tidak terduga.',
			'import.stepsTitle' => 'Cara mendapatkan URL',
			'import.step1' => 'Buka Riwayat Convene di Wuthering Waves dan tunggu halaman termuat.',
			'import.step2' => 'Salin URL riwayat convene. Isinya memuat svr_id, player_id, dan record_id.',
			'import.step3' => 'Tempel di bawah lalu ketuk Perbarui record.',
			'import.clear' => 'Hapus',
			'import.progressTitle' => 'Progres',
			'import.resultTitle' => 'Hasil',
			'import.viewRecords' => 'Lihat record',
			'import.retry' => 'Coba lagi',
			'import.close' => 'Tutup',
			'import.savedHint' => 'Memakai tautan yang tersimpan dari update terakhir. Jika sudah kedaluwarsa, Anda akan diminta tautan baru.',
			'import.fromFile' => 'Impor dari file JSON',
			'accounts.title' => 'Akun',
			'accounts.empty' => 'Belum ada akun. Impor URL convene untuk menambahkan.',
			'accounts.uid' => ({required Object uid}) => 'UID ${uid}',
			'accounts.active' => 'Aktif',
			'accounts.editAlias' => 'Ubah alias',
			'accounts.alias' => 'Alias',
			'accounts.delete' => 'Hapus akun',
			'accounts.deleteTitle' => 'Hapus akun?',
			'accounts.deleteBody' => ({required Object uid}) => 'Semua record UID ${uid} akan dihapus dari perangkat ini.',
			'accounts.save' => 'Simpan',
			'accounts.cancel' => 'Batal',
			'accounts.emptyTitle' => 'Belum ada akun',
			'accounts.addAccount' => 'Impor record',
			'accounts.sectionAll' => 'Akun Anda',
			'accounts.switchTitle' => 'Ganti akun',
			'accounts.actions' => 'Aksi',
			'accounts.sectionPrivacy' => 'Privasi',
			'accounts.maskUid' => 'Samarkan UID',
			'accounts.maskUidSubtitle' => 'Tampilkan hanya 3 digit pertama UID di seluruh aplikasi',
			'accounts.defaultName' => ({required Object n}) => 'Akun ${n}',
			'settings.title' => 'Pengaturan',
			'settings.appearance' => 'Tampilan',
			'settings.appearanceSubtitle' => 'Tema dan warna',
			'settings.data' => 'Data & penyimpanan',
			'settings.dataSubtitle' => 'Cadangan, cache gambar dan record tersimpan',
			'settings.about' => 'Tentang',
			'settings.aboutSubtitle' => 'Versi, sumber, dan disclaimer',
			'settings.accounts' => 'Akun',
			'settings.accountsSubtitle' => 'UID dan alias',
			'settings.import' => 'Impor record',
			'settings.importSubtitle' => 'Perbarui dari URL riwayat convene',
			'appearance.title' => 'Tampilan',
			'appearance.sectionColor' => 'Warna',
			'appearance.dynamicColor' => 'Warna dinamis',
			'appearance.dynamicColorSubtitle' => 'Gunakan warna dari wallpaper jika didukung platform',
			'appearance.accent' => 'Warna aksen',
			'appearance.sectionTheme' => 'Tema',
			'appearance.themeSystem' => 'Sistem',
			'appearance.themeLight' => 'Terang',
			'appearance.themeDark' => 'Gelap',
			'appearance.amoled' => 'Gelap AMOLED',
			'appearance.amoledSubtitle' => 'Latar hitam pekat pada mode gelap',
			'appearance.sectionLanguage' => 'Bahasa',
			'appearance.language' => 'Bahasa',
			'appearance.dataLanguage' => 'Bahasa data',
			'appearance.dataLanguageDesc' => 'Bahasa nama resonator dan senjata di record dan grafik Anda. Record yang tersimpan tidak diubah, dan item tanpa terjemahan tetap berbahasa Inggris.',
			'appearance.dataLanguageDefault' => 'English',
			'appearance.dataLanguageDefaultSubtitle' => 'Sesuai yang diambil dari game',
			'language.title' => 'Bahasa',
			'language.system' => 'Default sistem',
			'language.systemSubtitle' => 'Ikuti bahasa perangkat',
			'data.title' => 'Data & penyimpanan',
			'data.sectionCache' => 'Cache',
			'data.clearImages' => 'Hapus cache gambar',
			'data.clearImagesSubtitle' => 'Menghapus ikon item yang diunduh',
			'data.imagesCleared' => 'Cache gambar dihapus',
			'data.sectionRecords' => 'Record',
			'data.deleteAll' => 'Hapus semua data',
			'data.deleteAllSubtitle' => 'Menghapus semua akun dan record convene dari perangkat ini',
			'data.deleteAllTitle' => 'Hapus semua data?',
			'data.deleteAllBody' => 'Semua akun dan record akan dihapus permanen dari perangkat ini. Tindakan ini tidak bisa dibatalkan.',
			'data.deleted' => 'Semua data dihapus',
			'data.cancel' => 'Batal',
			'data.confirm' => 'Hapus',
			'data.sectionUsage' => 'Penyimpanan terpakai',
			'data.total' => 'Total',
			'data.database' => 'Database record',
			'data.databaseDetail' => ({required Object records, required Object accounts}) => '${records} record · ${accounts} akun',
			'data.imageCache' => 'Cache gambar',
			'data.calculating' => 'Menghitung…',
			'data.clearImagesTitle' => 'Hapus cache gambar?',
			'data.clearImagesBody' => 'Ikon item yang diunduh akan dihapus dan diunduh lagi saat dibutuhkan.',
			'data.clearImagesBodySize' => ({required Object size}) => 'Ikon item yang diunduh sebesar ${size} akan dihapus dan diunduh lagi saat dibutuhkan.',
			'data.clear' => 'Bersihkan',
			'data.sectionBackup' => 'Cadangan',
			'data.export' => 'Ekspor cadangan',
			'data.exportSubtitle' => 'Simpan semua akun dan record ke file JSON',
			'data.exportDone' => ({required Object records}) => '${records} record diekspor',
			'data.exportEmpty' => 'Belum ada data untuk diekspor',
			'data.exportFailed' => 'Gagal menyimpan file cadangan',
			'data.import' => 'Impor dari file',
			'data.importSubtitle' => 'Pulihkan cadangan, atau impor ekspor WuWa Tracker',
			'data.importDone' => ({required Object records, required Object accounts}) => '${records} record baru ditambahkan ke ${accounts} akun',
			'data.importNothingNew' => 'Tidak ada record baru di file ini',
			'data.importForeign' => 'Ini bukan cadangan Solaris Record maupun ekspor WuWa Tracker',
			'data.importInvalid' => 'File rusak atau formatnya tidak sesuai',
			'data.importTooNew' => 'Cadangan ini dibuat oleh versi aplikasi yang lebih baru',
			'data.importFailed' => 'Gagal mengimpor file',
			'data.sectionLogs' => 'Log debug',
			'data.logsHint' => 'Untuk laporan bug. UID dan tautan disamarkan.',
			'data.logsSize' => ({required Object size}) => '${size} log · UID dan tautan disamarkan',
			'data.exportLogs' => 'Ekspor log',
			'data.logsEmpty' => 'Belum ada log',
			'data.logsExported' => 'Log diekspor',
			'data.logsExportFailed' => 'Gagal menyimpan file log',
			'data.clearLogs' => 'Hapus log',
			'data.clearLogsTitle' => 'Hapus log?',
			'data.clearLogsBody' => 'Semua log debug yang tersimpan akan dihapus. Ekspor dulu jika Anda memerlukannya untuk laporan bug.',
			'data.logsCleared' => 'Log dihapus',
			'about.title' => 'Tentang',
			'about.version' => ({required Object version}) => 'Versi ${version}',
			'about.description' => 'Lacak riwayat convene Wuthering Waves di banyak akun: pity, pool, dan statistik.',
			'about.sectionInfo' => 'Informasi',
			'about.sourceTitle' => 'Sumber data',
			'about.sourceBody' => 'Record diambil dari layanan riwayat convene game memakai URL yang Anda tempel. Ikon item berasal dari guide server Kuro dan encore.moe.',
			'about.disclaimerTitle' => 'Disclaimer',
			'about.disclaimerBody' => 'Solaris Record adalah proyek penggemar tidak resmi, tidak berafiliasi dengan atau didukung Kuro Games. Wuthering Waves dan asetnya milik Kuro Games.',
			'about.licensesTitle' => 'Lisensi open source',
			'about.licensesBody' => 'Solaris Record adalah open source dengan lisensi MIT. Lihat lisensi pustaka dan font yang dipakainya.',
			'info.title' => 'Info item',
			'info.button' => 'Info item',
			'info.resonator' => 'Resonator',
			'info.weapon' => 'Senjata',
			'info.element' => 'Elemen',
			'info.weaponType' => 'Jenis senjata',
			'info.introduction' => 'Pengantar',
			'info.baseStats' => 'Statistik dasar (Lv. 1)',
			'info.baseStatsAtLevel' => 'Statistik dasar',
			'info.level' => 'Level',
			'info.skills' => 'Skill',
			'info.effect' => 'Efek senjata',
			'info.tags' => 'Tag',
			'info.error' => 'Gagal memuat info item. Periksa koneksi lalu coba lagi.',
			'info.notFound' => 'Info untuk item ini tidak tersedia.',
			'info.source' => 'Info dari encore.moe',
			'info.close' => 'Tutup',
			'info.viewOnEncore' => 'Lihat di encore.moe',
			'info.openFailed' => 'Tidak bisa membuka tautan.',
			'info.galleryIcon' => 'Ikon',
			'info.galleryOutfit' => 'Kostum',
			'info.galleryConvene' => 'Convene',
			'info.galleryPrevious' => 'Gambar sebelumnya',
			'info.galleryNext' => 'Gambar berikutnya',
			'info.imageSave' => 'Simpan gambar',
			'info.imageRefetch' => 'Ambil ulang gambar',
			'info.imageZoomIn' => 'Perbesar',
			'info.imageZoomOut' => 'Perkecil',
			'info.imageSaved' => 'Gambar disimpan',
			'info.imageSaveFailed' => 'Gagal menyimpan gambar',
			'info.imageLoadFailed' => 'Gagal memuat gambar',
			_ => null,
		};
	}
}
