///
/// Generated file. Do not edit.
///
// coverage:ignore-file
// ignore_for_file: type=lint, unused_import
// dart format off

part of 'strings.g.dart';

// Path: <root>
typedef TranslationsEn = Translations; // ignore: unused_element
class Translations with BaseTranslations<AppLocale, Translations> {
	/// Returns the current translations of the given [context].
	///
	/// Usage:
	/// final t = Translations.of(context);
	static Translations of(BuildContext context) => InheritedLocaleData.of<AppLocale, Translations>(context).translations;

	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	Translations({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<AppLocale, Translations>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  _meta = meta ?? TranslationMetadata(
		    locale: AppLocale.en,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ) {
		_meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <en>.
	final TranslationMetadata<AppLocale, Translations> _meta;
	@override TranslationMetadata<AppLocale, Translations> get $meta => _meta;

	/// Access flat map
	dynamic operator[](String key) => _meta.getTranslation(key);

	late final Translations _root = this; // ignore: unused_field

	Translations $copyWith({TranslationMetadata<AppLocale, Translations>? meta}) => Translations(meta: meta ?? this.$meta);

	// Translations

	/// en: 'Solaris Record'
	String get appName => 'Solaris Record';

	late final Translations$nav$en nav = Translations$nav$en.internal(_root);
	late final Translations$pools$en pools = Translations$pools$en.internal(_root);
	late final Translations$stats$en stats = Translations$stats$en.internal(_root);
	late final Translations$import$en import = Translations$import$en.internal(_root);
	late final Translations$accounts$en accounts = Translations$accounts$en.internal(_root);
	late final Translations$settings$en settings = Translations$settings$en.internal(_root);
	late final Translations$appearance$en appearance = Translations$appearance$en.internal(_root);
	late final Translations$language$en language = Translations$language$en.internal(_root);
	late final Translations$data$en data = Translations$data$en.internal(_root);
	late final Translations$about$en about = Translations$about$en.internal(_root);
	late final Translations$info$en info = Translations$info$en.internal(_root);
}

// Path: nav
class Translations$nav$en {
	Translations$nav$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Convene'
	String get stats => 'Convene';

	/// en: 'Settings'
	String get settings => 'Settings';

	/// en: 'Overview'
	String get overview => 'Overview';
}

// Path: pools
class Translations$pools$en {
	Translations$pools$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Featured Resonator'
	String get featuredResonator => 'Featured Resonator';

	/// en: 'Featured Weapon'
	String get featuredWeapon => 'Featured Weapon';

	/// en: 'Standard Resonator'
	String get standardResonator => 'Standard Resonator';

	/// en: 'Standard Weapon'
	String get standardWeapon => 'Standard Weapon';

	/// en: 'Beginner'
	String get beginner => 'Beginner';

	/// en: 'Beginner Choice'
	String get beginnerChoice => 'Beginner Choice';

	/// en: 'New Voyage Resonator'
	String get newVoyageResonator => 'New Voyage Resonator';

	/// en: 'New Voyage Weapon'
	String get newVoyageWeapon => 'New Voyage Weapon';

	/// en: 'Collab Resonator'
	String get collabResonator => 'Collab Resonator';

	/// en: 'Collab Weapon'
	String get collabWeapon => 'Collab Weapon';

	/// en: 'Reverb Resonator'
	String get reverbResonator => 'Reverb Resonator';

	/// en: 'Reverb Weapon'
	String get reverbWeapon => 'Reverb Weapon';
}

// Path: stats
class Translations$stats$en {
	Translations$stats$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'No account yet'
	String get noAccountTitle => 'No account yet';

	/// en: 'Import your convene record URL to get started.'
	String get noAccountBody => 'Import your convene record URL to get started.';

	/// en: 'Import records'
	String get goToImport => 'Import records';

	/// en: 'No pulls in this pool yet.'
	String get noPulls => 'No pulls in this pool yet.';

	/// en: '5★ pity'
	String get fiveStarPity => '5★ pity';

	/// en: '4★ pity'
	String get fourStarPity => '4★ pity';

	/// en: '{n} pulls until guaranteed'
	String pullsUntilHard({required Object n}) => '${n} pulls until guaranteed';

	/// en: 'Total pulls'
	String get total => 'Total pulls';

	/// en: '5★'
	String get fiveStars => '5★';

	/// en: '4★'
	String get fourStars => '4★';

	/// en: '3★'
	String get threeStars => '3★';

	/// en: 'Avg. pulls per 5★'
	String get average => 'Avg. pulls per 5★';

	/// en: '–'
	String get averageNone => '–';

	/// en: '50/50'
	String get fiftyFifty => '50/50';

	/// en: '{won} won · {lost} lost'
	String fiftyFiftyRecord({required Object won, required Object lost}) => '${won} won · ${lost} lost';

	/// en: 'Next 5★ is guaranteed featured'
	String get nextGuaranteed => 'Next 5★ is guaranteed featured';

	/// en: '5★ pulls'
	String get fiveStarTimeline => '5★ pulls';

	/// en: 'History'
	String get history => 'History';

	/// en: '{n} pulls'
	String pullsUsed({required Object n}) => '${n} pulls';

	/// en: 'Won 50/50'
	String get won => 'Won 50/50';

	/// en: 'Lost 50/50'
	String get lost => 'Lost 50/50';

	/// en: 'Guaranteed'
	String get guaranteed => 'Guaranteed';

	/// en: 'Pity'
	String get sectionPity => 'Pity';

	/// en: 'Overview'
	String get sectionOverview => 'Overview';

	/// en: 'Switch account'
	String get switchAccount => 'Switch account';

	/// en: '#{n}'
	String pullNumber({required Object n}) => '#${n}';

	/// en: 'All'
	String get filterAll => 'All';

	/// en: 'No records match this filter.'
	String get noMatches => 'No records match this filter.';

	/// en: 'Previous page'
	String get previousPage => 'Previous page';

	/// en: 'Next page'
	String get nextPage => 'Next page';

	/// en: 'Pulls'
	String get pullsLabel => 'Pulls';

	/// en: 'Time'
	String get detailTime => 'Time';

	/// en: 'Result'
	String get detailResult => 'Result';

	/// en: 'Pulls used'
	String get detailPity => 'Pulls used';

	/// en: 'Ring colors'
	String get legendTitle => 'Ring colors';

	/// en: '5★ count'
	String get countFive => '5★ count';

	/// en: '4★ count'
	String get countFour => '4★ count';

	/// en: '{pct}% of total'
	String ofTotal({required Object pct}) => '${pct}% of total';

	/// en: '{pct}% of total · Avg {avg} pulls'
	String ofTotalAvg({required Object pct, required Object avg}) => '${pct}% of total · Avg ${avg} pulls';

	/// en: '{n} 3★'
	String totalDetail({required Object n}) => '${n} 3★';

	/// en: '5★ timeline ({n})'
	String timelineTitle({required Object n}) => '5★ timeline (${n})';

	/// en: 'Now'
	String get timelineNow => 'Now';

	/// en: 'Lucky'
	String get luckLucky => 'Lucky';

	/// en: 'Average'
	String get luckAverage => 'Average';

	/// en: 'Unlucky'
	String get luckUnlucky => 'Unlucky';

	/// en: 'Avg {avg} pulls'
	String avgPulls({required Object avg}) => 'Avg ${avg} pulls';

	/// en: 'Search by name'
	String get searchHint => 'Search by name';

	/// en: 'Filter'
	String get filter => 'Filter';

	/// en: 'Filter history'
	String get filterTitle => 'Filter history';

	/// en: 'Rarity'
	String get filterRarity => 'Rarity';

	/// en: 'Type'
	String get filterType => 'Type';

	/// en: 'Sort'
	String get filterSort => 'Sort';

	/// en: 'Newest first'
	String get sortNewest => 'Newest first';

	/// en: 'Oldest first'
	String get sortOldest => 'Oldest first';

	/// en: 'Reset'
	String get filterReset => 'Reset';

	/// en: 'Apply'
	String get filterApply => 'Apply';

	/// en: '{n} results'
	String results({required Object n}) => '${n} results';

	/// en: 'Clear all'
	String get clearFilters => 'Clear all';

	/// en: '{n} result'
	String resultsOne({required Object n}) => '${n} result';

	/// en: 'Rows per page'
	String get rowsPerPage => 'Rows per page';

	/// en: '{from}–{to} of {total}'
	String rangeOf({required Object from, required Object to, required Object total}) => '${from}–${to} of ${total}';

	/// en: 'First page'
	String get firstPage => 'First page';

	/// en: 'Last page'
	String get lastPage => 'Last page';

	/// en: 'Pull types'
	String get poolTypes => 'Pull types';

	/// en: 'Show or hide pull types'
	String get togglePoolTypes => 'Show or hide pull types';

	/// en: 'Overview'
	String get overviewTitle => 'Overview';

	/// en: 'All pull types'
	String get overviewAll => 'All pull types';

	/// en: 'Rarity distribution'
	String get rarityDistribution => 'Rarity distribution';

	/// en: 'Type distribution'
	String get typeDistribution => 'Type distribution';

	/// en: 'Pity per pull type'
	String get pityPerType => 'Pity per pull type';

	/// en: '{n} pulls since last 5★'
	String sinceLastFive({required Object n}) => '${n} pulls since last 5★';

	/// en: 'No 5★ yet'
	String get noFiveYet => 'No 5★ yet';

	/// en: 'No pulls yet. Import your records to see the overview.'
	String get noPullsAnywhere => 'No pulls yet. Import your records to see the overview.';

	/// en: 'Update'
	String get updateShort => 'Update';

	/// en: 'Manage accounts'
	String get manageAccounts => 'Manage accounts';

	/// en: 'Time'
	String get sortFieldTime => 'Time';

	/// en: 'Name'
	String get sortFieldName => 'Name';

	/// en: 'Type'
	String get sortFieldType => 'Type';

	/// en: 'Rarity'
	String get sortFieldRarity => 'Rarity';

	/// en: 'Pity'
	String get sortFieldPity => 'Pity';

	/// en: 'Descending'
	String get sortDesc => 'Descending';

	/// en: 'Ascending'
	String get sortAsc => 'Ascending';

	/// en: 'Pity {n}'
	String pityShort({required Object n}) => 'Pity ${n}';

	/// en: '5★ per pull type'
	String get topRarityTitle => '5★ per pull type';

	/// en: '5★ timeline · all pull types'
	String get timelineAllTitle => '5★ timeline · all pull types';

	/// en: '{n} pulls since last 5★ across pull types'
	String timelineNowAll({required Object n}) => '${n} pulls since last 5★ across pull types';

	/// en: 'Show more ({n} left)'
	String timelineLoadMore({required Object n}) => 'Show more (${n} left)';

	/// en: 'Vertical view'
	String get timelineVertical => 'Vertical view';

	/// en: 'Horizontal view'
	String get timelineHorizontal => 'Horizontal view';
}

// Path: import
class Translations$import$en {
	Translations$import$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Import convene records'
	String get title => 'Import convene records';

	/// en: 'Open Convene History in the game, then copy the record URL and paste it here.'
	String get instructions => 'Open Convene History in the game, then copy the record URL and paste it here.';

	/// en: 'Convene record URL'
	String get urlLabel => 'Convene record URL';

	/// en: 'Paste'
	String get paste => 'Paste';

	/// en: 'Update records'
	String get update => 'Update records';

	/// en: 'Fetching {pool}…'
	String fetching({required Object pool}) => 'Fetching ${pool}…';

	/// en: 'Imported {n} new records for UID {uid}.'
	String done({required Object n, required Object uid}) => 'Imported ${n} new records for UID ${uid}.';

	/// en: 'That doesn't look like a convene record URL.'
	String get errorInvalidUrl => 'That doesn\'t look like a convene record URL.';

	/// en: 'The URL is missing: {params}.'
	String errorMissing({required Object params}) => 'The URL is missing: ${params}.';

	/// en: 'The URL was rejected or has expired. Open Convene History in the game again and copy a fresh URL.'
	String get errorExpired => 'The URL was rejected or has expired. Open Convene History in the game again and copy a fresh URL.';

	/// en: 'Too many requests. Wait a moment and try again.'
	String get errorRateLimited => 'Too many requests. Wait a moment and try again.';

	/// en: 'Network error. Check your connection and try again.'
	String get errorNetwork => 'Network error. Check your connection and try again.';

	/// en: 'Unexpected response from the server.'
	String get errorUnexpected => 'Unexpected response from the server.';

	/// en: 'How to get your URL'
	String get stepsTitle => 'How to get your URL';

	/// en: 'Open Convene History in Wuthering Waves and let the page load.'
	String get step1 => 'Open Convene History in Wuthering Waves and let the page load.';

	/// en: 'Copy the convene record URL. It contains svr_id, player_id and record_id.'
	String get step2 => 'Copy the convene record URL. It contains svr_id, player_id and record_id.';

	/// en: 'Paste it below and tap Update records.'
	String get step3 => 'Paste it below and tap Update records.';

	/// en: 'Clear'
	String get clear => 'Clear';

	/// en: 'Progress'
	String get progressTitle => 'Progress';

	/// en: 'Result'
	String get resultTitle => 'Result';

	/// en: 'View records'
	String get viewRecords => 'View records';

	/// en: 'Try again'
	String get retry => 'Try again';

	/// en: 'Close'
	String get close => 'Close';

	/// en: 'Using the link saved from your last update. If it has expired, you'll be asked for a new one.'
	String get savedHint => 'Using the link saved from your last update. If it has expired, you\'ll be asked for a new one.';

	/// en: 'Import from JSON file'
	String get fromFile => 'Import from JSON file';
}

// Path: accounts
class Translations$accounts$en {
	Translations$accounts$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Accounts'
	String get title => 'Accounts';

	/// en: 'No accounts yet. Import a convene URL to add one.'
	String get empty => 'No accounts yet. Import a convene URL to add one.';

	/// en: 'UID {uid}'
	String uid({required Object uid}) => 'UID ${uid}';

	/// en: 'Active'
	String get active => 'Active';

	/// en: 'Edit alias'
	String get editAlias => 'Edit alias';

	/// en: 'Alias'
	String get alias => 'Alias';

	/// en: 'Delete account'
	String get delete => 'Delete account';

	/// en: 'Delete account?'
	String get deleteTitle => 'Delete account?';

	/// en: 'All stored records for UID {uid} will be removed from this device.'
	String deleteBody({required Object uid}) => 'All stored records for UID ${uid} will be removed from this device.';

	/// en: 'Save'
	String get save => 'Save';

	/// en: 'Cancel'
	String get cancel => 'Cancel';

	/// en: 'No accounts yet'
	String get emptyTitle => 'No accounts yet';

	/// en: 'Import records'
	String get addAccount => 'Import records';

	/// en: 'Your accounts'
	String get sectionAll => 'Your accounts';

	/// en: 'Switch account'
	String get switchTitle => 'Switch account';

	/// en: 'Actions'
	String get actions => 'Actions';

	/// en: 'Privacy'
	String get sectionPrivacy => 'Privacy';

	/// en: 'Mask UID'
	String get maskUid => 'Mask UID';

	/// en: 'Show only the first 3 digits of UIDs throughout the app'
	String get maskUidSubtitle => 'Show only the first 3 digits of UIDs throughout the app';

	/// en: 'Account {n}'
	String defaultName({required Object n}) => 'Account ${n}';
}

// Path: settings
class Translations$settings$en {
	Translations$settings$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Settings'
	String get title => 'Settings';

	/// en: 'Appearance'
	String get appearance => 'Appearance';

	/// en: 'Theme and colors'
	String get appearanceSubtitle => 'Theme and colors';

	/// en: 'Data & storage'
	String get data => 'Data & storage';

	/// en: 'Backup, image cache and stored records'
	String get dataSubtitle => 'Backup, image cache and stored records';

	/// en: 'About'
	String get about => 'About';

	/// en: 'Version, sources and disclaimer'
	String get aboutSubtitle => 'Version, sources and disclaimer';

	/// en: 'Accounts'
	String get accounts => 'Accounts';

	/// en: 'UIDs and aliases'
	String get accountsSubtitle => 'UIDs and aliases';

	/// en: 'Import records'
	String get import => 'Import records';

	/// en: 'Update from a convene record URL'
	String get importSubtitle => 'Update from a convene record URL';
}

// Path: appearance
class Translations$appearance$en {
	Translations$appearance$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Appearance'
	String get title => 'Appearance';

	/// en: 'Color'
	String get sectionColor => 'Color';

	/// en: 'Dynamic color'
	String get dynamicColor => 'Dynamic color';

	/// en: 'Use colors from your wallpaper where the platform supports it'
	String get dynamicColorSubtitle => 'Use colors from your wallpaper where the platform supports it';

	/// en: 'Accent color'
	String get accent => 'Accent color';

	/// en: 'Theme'
	String get sectionTheme => 'Theme';

	/// en: 'System'
	String get themeSystem => 'System';

	/// en: 'Light'
	String get themeLight => 'Light';

	/// en: 'Dark'
	String get themeDark => 'Dark';

	/// en: 'AMOLED dark'
	String get amoled => 'AMOLED dark';

	/// en: 'Pure black background in dark mode'
	String get amoledSubtitle => 'Pure black background in dark mode';

	/// en: 'Language'
	String get sectionLanguage => 'Language';

	/// en: 'Language'
	String get language => 'Language';

	/// en: 'Data language'
	String get dataLanguage => 'Data language';

	/// en: 'Language of resonator and weapon names in your records and charts. Stored records are not changed, and items without a translation stay in English.'
	String get dataLanguageDesc => 'Language of resonator and weapon names in your records and charts. Stored records are not changed, and items without a translation stay in English.';

	/// en: 'English'
	String get dataLanguageDefault => 'English';

	/// en: 'As fetched from the game'
	String get dataLanguageDefaultSubtitle => 'As fetched from the game';
}

// Path: language
class Translations$language$en {
	Translations$language$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Language'
	String get title => 'Language';

	/// en: 'System default'
	String get system => 'System default';

	/// en: 'Follow your device language'
	String get systemSubtitle => 'Follow your device language';
}

// Path: data
class Translations$data$en {
	Translations$data$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Data & storage'
	String get title => 'Data & storage';

	/// en: 'Cache'
	String get sectionCache => 'Cache';

	/// en: 'Clear image cache'
	String get clearImages => 'Clear image cache';

	/// en: 'Removes downloaded item icons'
	String get clearImagesSubtitle => 'Removes downloaded item icons';

	/// en: 'Image cache cleared'
	String get imagesCleared => 'Image cache cleared';

	/// en: 'Records'
	String get sectionRecords => 'Records';

	/// en: 'Delete all data'
	String get deleteAll => 'Delete all data';

	/// en: 'Removes every account and convene record from this device'
	String get deleteAllSubtitle => 'Removes every account and convene record from this device';

	/// en: 'Delete all data?'
	String get deleteAllTitle => 'Delete all data?';

	/// en: 'All accounts and records will be permanently removed from this device. This can't be undone.'
	String get deleteAllBody => 'All accounts and records will be permanently removed from this device. This can\'t be undone.';

	/// en: 'All data deleted'
	String get deleted => 'All data deleted';

	/// en: 'Cancel'
	String get cancel => 'Cancel';

	/// en: 'Delete'
	String get confirm => 'Delete';

	/// en: 'Storage used'
	String get sectionUsage => 'Storage used';

	/// en: 'Total'
	String get total => 'Total';

	/// en: 'Records database'
	String get database => 'Records database';

	/// en: '{records} records · {accounts} accounts'
	String databaseDetail({required Object records, required Object accounts}) => '${records} records · ${accounts} accounts';

	/// en: 'Image cache'
	String get imageCache => 'Image cache';

	/// en: 'Calculating…'
	String get calculating => 'Calculating…';

	/// en: 'Clear image cache?'
	String get clearImagesTitle => 'Clear image cache?';

	/// en: 'Downloaded item icons will be removed and downloaded again when needed.'
	String get clearImagesBody => 'Downloaded item icons will be removed and downloaded again when needed.';

	/// en: '{size} of downloaded item icons will be removed and downloaded again when needed.'
	String clearImagesBodySize({required Object size}) => '${size} of downloaded item icons will be removed and downloaded again when needed.';

	/// en: 'Clear'
	String get clear => 'Clear';

	/// en: 'Backup'
	String get sectionBackup => 'Backup';

	/// en: 'Export backup'
	String get export => 'Export backup';

	/// en: 'Save all accounts and records to a JSON file'
	String get exportSubtitle => 'Save all accounts and records to a JSON file';

	/// en: 'Exported {records} records'
	String exportDone({required Object records}) => 'Exported ${records} records';

	/// en: 'There is nothing to export yet'
	String get exportEmpty => 'There is nothing to export yet';

	/// en: 'Couldn't save the backup file'
	String get exportFailed => 'Couldn\'t save the backup file';

	/// en: 'Import from file'
	String get import => 'Import from file';

	/// en: 'Restore a backup, or import a WuWa Tracker export'
	String get importSubtitle => 'Restore a backup, or import a WuWa Tracker export';

	/// en: 'Added {records} new records to {accounts} accounts'
	String importDone({required Object records, required Object accounts}) => 'Added ${records} new records to ${accounts} accounts';

	/// en: 'No new records in this file'
	String get importNothingNew => 'No new records in this file';

	/// en: 'This isn't a Solaris Record backup or a WuWa Tracker export'
	String get importForeign => 'This isn\'t a Solaris Record backup or a WuWa Tracker export';

	/// en: 'The file is damaged or has an unexpected format'
	String get importInvalid => 'The file is damaged or has an unexpected format';

	/// en: 'This backup was made by a newer version of the app'
	String get importTooNew => 'This backup was made by a newer version of the app';

	/// en: 'Couldn't import the file'
	String get importFailed => 'Couldn\'t import the file';

	/// en: 'Debug logs'
	String get sectionLogs => 'Debug logs';

	/// en: 'For bug reports. UIDs and links are masked.'
	String get logsHint => 'For bug reports. UIDs and links are masked.';

	/// en: '{size} of logs · UIDs and links are masked'
	String logsSize({required Object size}) => '${size} of logs · UIDs and links are masked';

	/// en: 'Export logs'
	String get exportLogs => 'Export logs';

	/// en: 'There are no logs yet'
	String get logsEmpty => 'There are no logs yet';

	/// en: 'Logs exported'
	String get logsExported => 'Logs exported';

	/// en: 'Couldn't save the log file'
	String get logsExportFailed => 'Couldn\'t save the log file';

	/// en: 'Clear logs'
	String get clearLogs => 'Clear logs';

	/// en: 'Clear logs?'
	String get clearLogsTitle => 'Clear logs?';

	/// en: 'All stored debug logs will be deleted. Export them first if you need them for a bug report.'
	String get clearLogsBody => 'All stored debug logs will be deleted. Export them first if you need them for a bug report.';

	/// en: 'Logs cleared'
	String get logsCleared => 'Logs cleared';
}

// Path: about
class Translations$about$en {
	Translations$about$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'About'
	String get title => 'About';

	/// en: 'Version {version}'
	String version({required Object version}) => 'Version ${version}';

	/// en: 'Track your Wuthering Waves convene history across multiple accounts: pity, pools and statistics.'
	String get description => 'Track your Wuthering Waves convene history across multiple accounts: pity, pools and statistics.';

	/// en: 'Information'
	String get sectionInfo => 'Information';

	/// en: 'Data source'
	String get sourceTitle => 'Data source';

	/// en: 'Records are fetched from the game's convene record service using the URL you paste. Item icons come from Kuro's guide server and encore.moe.'
	String get sourceBody => 'Records are fetched from the game\'s convene record service using the URL you paste. Item icons come from Kuro\'s guide server and encore.moe.';

	/// en: 'Disclaimer'
	String get disclaimerTitle => 'Disclaimer';

	/// en: 'Solaris Record is an unofficial fan project, not affiliated with or endorsed by Kuro Games. Wuthering Waves and its assets belong to Kuro Games.'
	String get disclaimerBody => 'Solaris Record is an unofficial fan project, not affiliated with or endorsed by Kuro Games. Wuthering Waves and its assets belong to Kuro Games.';

	/// en: 'Open source licenses'
	String get licensesTitle => 'Open source licenses';

	/// en: 'Solaris Record is open source under the MIT license. See the licenses of the libraries and fonts it uses.'
	String get licensesBody => 'Solaris Record is open source under the MIT license. See the licenses of the libraries and fonts it uses.';
}

// Path: info
class Translations$info$en {
	Translations$info$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Item info'
	String get title => 'Item info';

	/// en: 'Item info'
	String get button => 'Item info';

	/// en: 'Resonator'
	String get resonator => 'Resonator';

	/// en: 'Weapon'
	String get weapon => 'Weapon';

	/// en: 'Element'
	String get element => 'Element';

	/// en: 'Weapon type'
	String get weaponType => 'Weapon type';

	/// en: 'Introduction'
	String get introduction => 'Introduction';

	/// en: 'Base stats (Lv. 1)'
	String get baseStats => 'Base stats (Lv. 1)';

	/// en: 'Base stats'
	String get baseStatsAtLevel => 'Base stats';

	/// en: 'Level'
	String get level => 'Level';

	/// en: 'Skills'
	String get skills => 'Skills';

	/// en: 'Weapon effect'
	String get effect => 'Weapon effect';

	/// en: 'Tags'
	String get tags => 'Tags';

	/// en: 'Couldn't load item info. Check your connection and try again.'
	String get error => 'Couldn\'t load item info. Check your connection and try again.';

	/// en: 'No info available for this item.'
	String get notFound => 'No info available for this item.';

	/// en: 'Info from encore.moe'
	String get source => 'Info from encore.moe';

	/// en: 'Close'
	String get close => 'Close';

	/// en: 'View on encore.moe'
	String get viewOnEncore => 'View on encore.moe';

	/// en: 'Couldn't open the link.'
	String get openFailed => 'Couldn\'t open the link.';

	/// en: 'Icon'
	String get galleryIcon => 'Icon';

	/// en: 'Outfit'
	String get galleryOutfit => 'Outfit';

	/// en: 'Convene'
	String get galleryConvene => 'Convene';

	/// en: 'Previous image'
	String get galleryPrevious => 'Previous image';

	/// en: 'Next image'
	String get galleryNext => 'Next image';

	/// en: 'Save image'
	String get imageSave => 'Save image';

	/// en: 'Re-fetch image'
	String get imageRefetch => 'Re-fetch image';

	/// en: 'Zoom in'
	String get imageZoomIn => 'Zoom in';

	/// en: 'Zoom out'
	String get imageZoomOut => 'Zoom out';

	/// en: 'Image saved'
	String get imageSaved => 'Image saved';

	/// en: 'Couldn't save the image'
	String get imageSaveFailed => 'Couldn\'t save the image';

	/// en: 'Couldn't load the image'
	String get imageLoadFailed => 'Couldn\'t load the image';
}

/// The flat map containing all translations for locale <en>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on Translations {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'appName' => 'Solaris Record',
			'nav.stats' => 'Convene',
			'nav.settings' => 'Settings',
			'nav.overview' => 'Overview',
			'pools.featuredResonator' => 'Featured Resonator',
			'pools.featuredWeapon' => 'Featured Weapon',
			'pools.standardResonator' => 'Standard Resonator',
			'pools.standardWeapon' => 'Standard Weapon',
			'pools.beginner' => 'Beginner',
			'pools.beginnerChoice' => 'Beginner Choice',
			'pools.newVoyageResonator' => 'New Voyage Resonator',
			'pools.newVoyageWeapon' => 'New Voyage Weapon',
			'pools.collabResonator' => 'Collab Resonator',
			'pools.collabWeapon' => 'Collab Weapon',
			'pools.reverbResonator' => 'Reverb Resonator',
			'pools.reverbWeapon' => 'Reverb Weapon',
			'stats.noAccountTitle' => 'No account yet',
			'stats.noAccountBody' => 'Import your convene record URL to get started.',
			'stats.goToImport' => 'Import records',
			'stats.noPulls' => 'No pulls in this pool yet.',
			'stats.fiveStarPity' => '5★ pity',
			'stats.fourStarPity' => '4★ pity',
			'stats.pullsUntilHard' => ({required Object n}) => '${n} pulls until guaranteed',
			'stats.total' => 'Total pulls',
			'stats.fiveStars' => '5★',
			'stats.fourStars' => '4★',
			'stats.threeStars' => '3★',
			'stats.average' => 'Avg. pulls per 5★',
			'stats.averageNone' => '–',
			'stats.fiftyFifty' => '50/50',
			'stats.fiftyFiftyRecord' => ({required Object won, required Object lost}) => '${won} won · ${lost} lost',
			'stats.nextGuaranteed' => 'Next 5★ is guaranteed featured',
			'stats.fiveStarTimeline' => '5★ pulls',
			'stats.history' => 'History',
			'stats.pullsUsed' => ({required Object n}) => '${n} pulls',
			'stats.won' => 'Won 50/50',
			'stats.lost' => 'Lost 50/50',
			'stats.guaranteed' => 'Guaranteed',
			'stats.sectionPity' => 'Pity',
			'stats.sectionOverview' => 'Overview',
			'stats.switchAccount' => 'Switch account',
			'stats.pullNumber' => ({required Object n}) => '#${n}',
			'stats.filterAll' => 'All',
			'stats.noMatches' => 'No records match this filter.',
			'stats.previousPage' => 'Previous page',
			'stats.nextPage' => 'Next page',
			'stats.pullsLabel' => 'Pulls',
			'stats.detailTime' => 'Time',
			'stats.detailResult' => 'Result',
			'stats.detailPity' => 'Pulls used',
			'stats.legendTitle' => 'Ring colors',
			'stats.countFive' => '5★ count',
			'stats.countFour' => '4★ count',
			'stats.ofTotal' => ({required Object pct}) => '${pct}% of total',
			'stats.ofTotalAvg' => ({required Object pct, required Object avg}) => '${pct}% of total · Avg ${avg} pulls',
			'stats.totalDetail' => ({required Object n}) => '${n} 3★',
			'stats.timelineTitle' => ({required Object n}) => '5★ timeline (${n})',
			'stats.timelineNow' => 'Now',
			'stats.luckLucky' => 'Lucky',
			'stats.luckAverage' => 'Average',
			'stats.luckUnlucky' => 'Unlucky',
			'stats.avgPulls' => ({required Object avg}) => 'Avg ${avg} pulls',
			'stats.searchHint' => 'Search by name',
			'stats.filter' => 'Filter',
			'stats.filterTitle' => 'Filter history',
			'stats.filterRarity' => 'Rarity',
			'stats.filterType' => 'Type',
			'stats.filterSort' => 'Sort',
			'stats.sortNewest' => 'Newest first',
			'stats.sortOldest' => 'Oldest first',
			'stats.filterReset' => 'Reset',
			'stats.filterApply' => 'Apply',
			'stats.results' => ({required Object n}) => '${n} results',
			'stats.clearFilters' => 'Clear all',
			'stats.resultsOne' => ({required Object n}) => '${n} result',
			'stats.rowsPerPage' => 'Rows per page',
			'stats.rangeOf' => ({required Object from, required Object to, required Object total}) => '${from}–${to} of ${total}',
			'stats.firstPage' => 'First page',
			'stats.lastPage' => 'Last page',
			'stats.poolTypes' => 'Pull types',
			'stats.togglePoolTypes' => 'Show or hide pull types',
			'stats.overviewTitle' => 'Overview',
			'stats.overviewAll' => 'All pull types',
			'stats.rarityDistribution' => 'Rarity distribution',
			'stats.typeDistribution' => 'Type distribution',
			'stats.pityPerType' => 'Pity per pull type',
			'stats.sinceLastFive' => ({required Object n}) => '${n} pulls since last 5★',
			'stats.noFiveYet' => 'No 5★ yet',
			'stats.noPullsAnywhere' => 'No pulls yet. Import your records to see the overview.',
			'stats.updateShort' => 'Update',
			'stats.manageAccounts' => 'Manage accounts',
			'stats.sortFieldTime' => 'Time',
			'stats.sortFieldName' => 'Name',
			'stats.sortFieldType' => 'Type',
			'stats.sortFieldRarity' => 'Rarity',
			'stats.sortFieldPity' => 'Pity',
			'stats.sortDesc' => 'Descending',
			'stats.sortAsc' => 'Ascending',
			'stats.pityShort' => ({required Object n}) => 'Pity ${n}',
			'stats.topRarityTitle' => '5★ per pull type',
			'stats.timelineAllTitle' => '5★ timeline · all pull types',
			'stats.timelineNowAll' => ({required Object n}) => '${n} pulls since last 5★ across pull types',
			'stats.timelineLoadMore' => ({required Object n}) => 'Show more (${n} left)',
			'stats.timelineVertical' => 'Vertical view',
			'stats.timelineHorizontal' => 'Horizontal view',
			'import.title' => 'Import convene records',
			'import.instructions' => 'Open Convene History in the game, then copy the record URL and paste it here.',
			'import.urlLabel' => 'Convene record URL',
			'import.paste' => 'Paste',
			'import.update' => 'Update records',
			'import.fetching' => ({required Object pool}) => 'Fetching ${pool}…',
			'import.done' => ({required Object n, required Object uid}) => 'Imported ${n} new records for UID ${uid}.',
			'import.errorInvalidUrl' => 'That doesn\'t look like a convene record URL.',
			'import.errorMissing' => ({required Object params}) => 'The URL is missing: ${params}.',
			'import.errorExpired' => 'The URL was rejected or has expired. Open Convene History in the game again and copy a fresh URL.',
			'import.errorRateLimited' => 'Too many requests. Wait a moment and try again.',
			'import.errorNetwork' => 'Network error. Check your connection and try again.',
			'import.errorUnexpected' => 'Unexpected response from the server.',
			'import.stepsTitle' => 'How to get your URL',
			'import.step1' => 'Open Convene History in Wuthering Waves and let the page load.',
			'import.step2' => 'Copy the convene record URL. It contains svr_id, player_id and record_id.',
			'import.step3' => 'Paste it below and tap Update records.',
			'import.clear' => 'Clear',
			'import.progressTitle' => 'Progress',
			'import.resultTitle' => 'Result',
			'import.viewRecords' => 'View records',
			'import.retry' => 'Try again',
			'import.close' => 'Close',
			'import.savedHint' => 'Using the link saved from your last update. If it has expired, you\'ll be asked for a new one.',
			'import.fromFile' => 'Import from JSON file',
			'accounts.title' => 'Accounts',
			'accounts.empty' => 'No accounts yet. Import a convene URL to add one.',
			'accounts.uid' => ({required Object uid}) => 'UID ${uid}',
			'accounts.active' => 'Active',
			'accounts.editAlias' => 'Edit alias',
			'accounts.alias' => 'Alias',
			'accounts.delete' => 'Delete account',
			'accounts.deleteTitle' => 'Delete account?',
			'accounts.deleteBody' => ({required Object uid}) => 'All stored records for UID ${uid} will be removed from this device.',
			'accounts.save' => 'Save',
			'accounts.cancel' => 'Cancel',
			'accounts.emptyTitle' => 'No accounts yet',
			'accounts.addAccount' => 'Import records',
			'accounts.sectionAll' => 'Your accounts',
			'accounts.switchTitle' => 'Switch account',
			'accounts.actions' => 'Actions',
			'accounts.sectionPrivacy' => 'Privacy',
			'accounts.maskUid' => 'Mask UID',
			'accounts.maskUidSubtitle' => 'Show only the first 3 digits of UIDs throughout the app',
			'accounts.defaultName' => ({required Object n}) => 'Account ${n}',
			'settings.title' => 'Settings',
			'settings.appearance' => 'Appearance',
			'settings.appearanceSubtitle' => 'Theme and colors',
			'settings.data' => 'Data & storage',
			'settings.dataSubtitle' => 'Backup, image cache and stored records',
			'settings.about' => 'About',
			'settings.aboutSubtitle' => 'Version, sources and disclaimer',
			'settings.accounts' => 'Accounts',
			'settings.accountsSubtitle' => 'UIDs and aliases',
			'settings.import' => 'Import records',
			'settings.importSubtitle' => 'Update from a convene record URL',
			'appearance.title' => 'Appearance',
			'appearance.sectionColor' => 'Color',
			'appearance.dynamicColor' => 'Dynamic color',
			'appearance.dynamicColorSubtitle' => 'Use colors from your wallpaper where the platform supports it',
			'appearance.accent' => 'Accent color',
			'appearance.sectionTheme' => 'Theme',
			'appearance.themeSystem' => 'System',
			'appearance.themeLight' => 'Light',
			'appearance.themeDark' => 'Dark',
			'appearance.amoled' => 'AMOLED dark',
			'appearance.amoledSubtitle' => 'Pure black background in dark mode',
			'appearance.sectionLanguage' => 'Language',
			'appearance.language' => 'Language',
			'appearance.dataLanguage' => 'Data language',
			'appearance.dataLanguageDesc' => 'Language of resonator and weapon names in your records and charts. Stored records are not changed, and items without a translation stay in English.',
			'appearance.dataLanguageDefault' => 'English',
			'appearance.dataLanguageDefaultSubtitle' => 'As fetched from the game',
			'language.title' => 'Language',
			'language.system' => 'System default',
			'language.systemSubtitle' => 'Follow your device language',
			'data.title' => 'Data & storage',
			'data.sectionCache' => 'Cache',
			'data.clearImages' => 'Clear image cache',
			'data.clearImagesSubtitle' => 'Removes downloaded item icons',
			'data.imagesCleared' => 'Image cache cleared',
			'data.sectionRecords' => 'Records',
			'data.deleteAll' => 'Delete all data',
			'data.deleteAllSubtitle' => 'Removes every account and convene record from this device',
			'data.deleteAllTitle' => 'Delete all data?',
			'data.deleteAllBody' => 'All accounts and records will be permanently removed from this device. This can\'t be undone.',
			'data.deleted' => 'All data deleted',
			'data.cancel' => 'Cancel',
			'data.confirm' => 'Delete',
			'data.sectionUsage' => 'Storage used',
			'data.total' => 'Total',
			'data.database' => 'Records database',
			'data.databaseDetail' => ({required Object records, required Object accounts}) => '${records} records · ${accounts} accounts',
			'data.imageCache' => 'Image cache',
			'data.calculating' => 'Calculating…',
			'data.clearImagesTitle' => 'Clear image cache?',
			'data.clearImagesBody' => 'Downloaded item icons will be removed and downloaded again when needed.',
			'data.clearImagesBodySize' => ({required Object size}) => '${size} of downloaded item icons will be removed and downloaded again when needed.',
			'data.clear' => 'Clear',
			'data.sectionBackup' => 'Backup',
			'data.export' => 'Export backup',
			'data.exportSubtitle' => 'Save all accounts and records to a JSON file',
			'data.exportDone' => ({required Object records}) => 'Exported ${records} records',
			'data.exportEmpty' => 'There is nothing to export yet',
			'data.exportFailed' => 'Couldn\'t save the backup file',
			'data.import' => 'Import from file',
			'data.importSubtitle' => 'Restore a backup, or import a WuWa Tracker export',
			'data.importDone' => ({required Object records, required Object accounts}) => 'Added ${records} new records to ${accounts} accounts',
			'data.importNothingNew' => 'No new records in this file',
			'data.importForeign' => 'This isn\'t a Solaris Record backup or a WuWa Tracker export',
			'data.importInvalid' => 'The file is damaged or has an unexpected format',
			'data.importTooNew' => 'This backup was made by a newer version of the app',
			'data.importFailed' => 'Couldn\'t import the file',
			'data.sectionLogs' => 'Debug logs',
			'data.logsHint' => 'For bug reports. UIDs and links are masked.',
			'data.logsSize' => ({required Object size}) => '${size} of logs · UIDs and links are masked',
			'data.exportLogs' => 'Export logs',
			'data.logsEmpty' => 'There are no logs yet',
			'data.logsExported' => 'Logs exported',
			'data.logsExportFailed' => 'Couldn\'t save the log file',
			'data.clearLogs' => 'Clear logs',
			'data.clearLogsTitle' => 'Clear logs?',
			'data.clearLogsBody' => 'All stored debug logs will be deleted. Export them first if you need them for a bug report.',
			'data.logsCleared' => 'Logs cleared',
			'about.title' => 'About',
			'about.version' => ({required Object version}) => 'Version ${version}',
			'about.description' => 'Track your Wuthering Waves convene history across multiple accounts: pity, pools and statistics.',
			'about.sectionInfo' => 'Information',
			'about.sourceTitle' => 'Data source',
			'about.sourceBody' => 'Records are fetched from the game\'s convene record service using the URL you paste. Item icons come from Kuro\'s guide server and encore.moe.',
			'about.disclaimerTitle' => 'Disclaimer',
			'about.disclaimerBody' => 'Solaris Record is an unofficial fan project, not affiliated with or endorsed by Kuro Games. Wuthering Waves and its assets belong to Kuro Games.',
			'about.licensesTitle' => 'Open source licenses',
			'about.licensesBody' => 'Solaris Record is open source under the MIT license. See the licenses of the libraries and fonts it uses.',
			'info.title' => 'Item info',
			'info.button' => 'Item info',
			'info.resonator' => 'Resonator',
			'info.weapon' => 'Weapon',
			'info.element' => 'Element',
			'info.weaponType' => 'Weapon type',
			'info.introduction' => 'Introduction',
			'info.baseStats' => 'Base stats (Lv. 1)',
			'info.baseStatsAtLevel' => 'Base stats',
			'info.level' => 'Level',
			'info.skills' => 'Skills',
			'info.effect' => 'Weapon effect',
			'info.tags' => 'Tags',
			'info.error' => 'Couldn\'t load item info. Check your connection and try again.',
			'info.notFound' => 'No info available for this item.',
			'info.source' => 'Info from encore.moe',
			'info.close' => 'Close',
			'info.viewOnEncore' => 'View on encore.moe',
			'info.openFailed' => 'Couldn\'t open the link.',
			'info.galleryIcon' => 'Icon',
			'info.galleryOutfit' => 'Outfit',
			'info.galleryConvene' => 'Convene',
			'info.galleryPrevious' => 'Previous image',
			'info.galleryNext' => 'Next image',
			'info.imageSave' => 'Save image',
			'info.imageRefetch' => 'Re-fetch image',
			'info.imageZoomIn' => 'Zoom in',
			'info.imageZoomOut' => 'Zoom out',
			'info.imageSaved' => 'Image saved',
			'info.imageSaveFailed' => 'Couldn\'t save the image',
			'info.imageLoadFailed' => 'Couldn\'t load the image',
			_ => null,
		};
	}
}
