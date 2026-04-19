import Foundation

/// ライブラリ中間階層の 1 行（カノン・連作・物語ポータルなど）。
struct LibraryItem: Identifiable, Hashable, Sendable {
    let id: String
    /// `Localizable.strings` のキー（`en` / `ja` の両方に定義）。
    let titleLocalizationKey: String
    /// HTML 等から注入する表示用タイトル。`nil` のときは `titleLocalizationKey` を表示。
    let title: String?
    let url: URL
    /// サイトの掲載順（「作成順」など）。大きいほど新しい。
    let wikiCreationOrder: Int
    /// 主著者のソート用キー（ローマ字小文字推奨）。空なら著者系並べ替えではタイトルにフォールバック。
    let primaryAuthorSortKey: String
}

extension Array where Element == LibraryItem {
    /// 並べ替え。`titleKey` はローカライズ済みタイトル。
    func sortedLibraryItems(mode: LibraryListSortMode, titleKey: (LibraryItem) -> String, locale: Locale) -> [LibraryItem] {
        func authorKey(_ item: LibraryItem) -> String {
            item.primaryAuthorSortKey.isEmpty ? titleKey(item) : item.primaryAuthorSortKey
        }
        switch mode {
        case .wikiOrder:
            return sorted { $0.wikiCreationOrder < $1.wikiCreationOrder }
        case .titleAscending:
            return sorted { a, b in
                let cmp = titleKey(a).compare(titleKey(b), options: [.caseInsensitive, .widthInsensitive], locale: locale)
                if cmp == .orderedSame { return a.id < b.id }
                return cmp == .orderedAscending
            }
        case .titleDescending:
            return sorted { a, b in
                let cmp = titleKey(a).compare(titleKey(b), options: [.caseInsensitive, .widthInsensitive], locale: locale)
                if cmp == .orderedSame { return a.id < b.id }
                return cmp == .orderedDescending
            }
        case .newestFirst:
            return sorted { a, b in
                if a.wikiCreationOrder != b.wikiCreationOrder { return a.wikiCreationOrder > b.wikiCreationOrder }
                return a.id < b.id
            }
        case .oldestFirst:
            return sorted { a, b in
                if a.wikiCreationOrder != b.wikiCreationOrder { return a.wikiCreationOrder < b.wikiCreationOrder }
                return a.id < b.id
            }
        case .primaryAuthorAscending:
            return sorted { a, b in
                let cmp = authorKey(a).compare(authorKey(b), options: [.caseInsensitive, .widthInsensitive], locale: locale)
                if cmp == .orderedSame { return a.id < b.id }
                return cmp == .orderedAscending
            }
        case .primaryAuthorHubCountDescending:
            let counts = Dictionary(grouping: filter { !$0.primaryAuthorSortKey.isEmpty }, by: \.primaryAuthorSortKey)
                .mapValues { $0.count }
            return sorted { a, b in
                let ca = counts[a.primaryAuthorSortKey, default: 0]
                let cb = counts[b.primaryAuthorSortKey, default: 0]
                if ca != cb { return ca > cb }
                let cmp = titleKey(a).compare(titleKey(b), options: [.caseInsensitive, .widthInsensitive], locale: locale)
                if cmp == .orderedSame { return a.id < b.id }
                return cmp == .orderedAscending
            }
        }
    }
}

/// Wikidot ハブページのリンク一覧（支部ごとにサイトが異なる）。
enum LibraryStaticData: Sendable {
    static func items(category: LibraryCategory, branch: Branch) -> [LibraryItem] {
        switch branch.id {
        case BranchIdentifier.scpJapan:
            return japanItems(for: category)
        default:
            return englishItems(for: category)
        }
    }

    private static func englishItems(for category: LibraryCategory) -> [LibraryItem] {
        let base = URL(string: "https://scp-wiki.wikidot.com/")!
        switch category {
        case .tales:
            return [
                item("curated-tale-series", "library.item.curated_tale_series", base, 1),
                item("featured-tale-archive-ii", "library.item.featured_tale_archive_ii", base, 2),
                item("joke-scps-tales-edition", "library.item.joke_scps_tales_edition", base, 3),
                item("explained-scps-tales-edition", "library.item.explained_scps_tales_edition", base, 4),
                item("foundation-tales-audio-edition", "library.item.foundation_tales_audio_edition", base, 5),
                item("creepy-pasta", "library.item.creepy_pasta", base, 6),
                item("incident-reports-eye-witness-interviews-and-personal-logs", "library.item.incident_reports_eye_witness", base, 7),
                item("curated-lists", "library.item.curated_lists", base, 8)
            ]
        case .canons:
            return [
                item("broken-masquerade-hub", "library.item.broken_masquerade_hub", base, 1),
                item("third-law-hub", "library.item.third_law_hub", base, 2),
                item("end-of-death-hub", "library.item.end_of_death_hub", base, 3),
                item("rat-s-nest-hub", "library.item.rat_s_nest_hub", base, 4),
                item("cool-war-2-hub", "library.item.cool_war_2_hub", base, 5),
                item("pitch-haven-hub", "library.item.pitch_haven_hub", base, 6),
                item("only-game-in-town-hub", "library.item.only_game_in_town_hub", base, 7),
                item("the-coldest-war-hub", "library.item.the_coldest_war_hub", base, 8),
                item("competitive-eschatology-hub", "library.item.competitive_eschatology_hub", base, 9),
                item("dread-circuses-hub", "library.item.dread_circuses_hub", base, 10)
            ]
        case .goi:
            return englishGoIItems()
        case .series:
            return [
                item("antimemetics-division-hub", "library.item.antimemetics_division_hub", base, 1),
                item("anabasis-hub", "library.item.anabasis_hub", base, 2),
                item("deadlined-hub", "library.item.deadlined_hub", base, 3),
                item("on-mount-golgotha-hub", "library.item.on_mount_golgotha_hub", base, 4),
                item("bury-the-survivors-hub", "library.item.bury_the_survivors_hub", base, 5),
                item("creative-destruction-hub", "library.item.creative_destruction_hub", base, 6),
                item("hecatoncheires-cycle-hub", "library.item.hecatoncheires_cycle_hub", base, 7),
                item("integration-program-hub", "library.item.integration_program_hub", base, 8)
            ]
        }
    }

    /// `research/html_canon-jp.txt` の「作成順」目次および本文パネル順に準拠。
    private static func japanItems(for category: LibraryCategory) -> [LibraryItem] {
        let base = URL(string: "https://scp-jp.wikidot.com/")!
        switch category {
        case .tales:
            return [
                item("anthology-hub-jp", "library.item.anthology_hub_jp", base, 1),
                item("collaboration-hub-jp", "library.item.collaboration_hub_jp", base, 2),
                item("event-archive-jp", "library.item.event_archive_jp", base, 3),
                item("series-archive-jp", "library.item.series_archive_jp", base, 4),
                item("supplement-hub-jp", "library.item.supplement_hub_jp", base, 5),
                item("1200-taletaletale-hub", "library.item.1200_taletaletale_hub", base, 6),
                item("archives-f", "library.item.archives_f", base, 7),
                item("gamers-against-weed-hub", "library.item.gamers_against_weed_hub", base, 8),
                item("guide-for-newbies", "library.item.guide_for_newbies", base, 9),
                item("hyogaki-hub", "library.item.hyogaki_hub", base, 10)
            ]
        case .canons:
            return [
                item("canon-jp-2", "library.item.canon_jp_2", base, 1, "mary0228"),
                item("officer-doctor-soldier-spy-hub", "library.item.officer_doctor_soldier_spy_hub", base, 2, "karkaroff"),
                item("fusouki", "library.item.fusouki", base, 3, "shirasutaro"),
                item("1998-hub", "library.item.1998_hub", base, 4, "islandsmaster"),
                item("sushiblade-hub", "library.item.sushiblade_hub", base, 5, "bamboon"),
                item("foundation-collective-hub", "library.item.foundation_collective_hub", base, 6, "amamiel"),
                item("absinthiana-dream", "library.item.absinthiana_dream", base, 7),
                item("yotsujikigeki-hub", "library.item.yotsujikigeki_hub", base, 8, "aisurakuto"),
                item("making-2000-hub", "library.item.making_2000_hub", base, 9, "machikawa"),
                item("holding-grails-hub", "library.item.holding_grails_hub", base, 10, "islandsmaster"),
                item("kyouikaireki-hub", "library.item.kyouikaireki_hub", base, 11, "k-cal"),
                item("prosopagnosia-hub", "library.item.prosopagnosia_hub", base, 12, "h0h0"),
                item("chiisanazaidan-hub", "library.item.chiisanazaidan_hub", base, 13, "yzkrt"),
                item("polar-light", "library.item.polar_light", base, 14, "machikawa"),
                item("double-hometown-hub", "library.item.double_hometown_hub", base, 15, "amadai"),
                item("thanatomania-hub", "library.item.thanatomania_hub", base, 16, "rivi-era"),
                item("taisho150-hub", "library.item.taisho150_hub", base, 17, "koikoi_rainy4l"),
                item("poor-foundation-hub", "library.item.poor_foundation_hub", base, 18, "kskhorn"),
                item("hyogaki-hub", "library.item.hyogaki_hub", base, 19, "nemo111"),
                item("kaiki-meimeiden-hub", "library.item.kaiki_meimeiden_hub", base, 20, "str0717"),
                item("practical-examination-hub", "library.item.practical_examination_hub", base, 21, "jiraku_mogana")
            ]
        case .goi:
            // 日本支部の要注意団体は `GoILibraryHierarchyData`＋`LibraryListView` の階層表示を使う。
            return []
        case .series:
            return [
                item("bounenkai", "library.item.bounenkai", base, 1),
                item("foundation-summer-festival", "library.item.foundation_summer_festival", base, 2),
                item("tataro-yoke", "library.item.tataro_yoke", base, 3),
                item("monster-decisive-battle-hub", "library.item.monster_decisive_battle_hub", base, 4),
                item("after-party-hub", "library.item.after_party_hub", base, 5),
                item("goede-film-hub", "library.item.goede_film_hub", base, 6),
                item("aonibiiro-hub", "library.item.aonibiiro_hub", base, 7),
                item("autopsy-hub", "library.item.autopsy_hub", base, 8),
                item("shironose-hub", "library.item.shironose_hub", base, 9),
                item("rror-hub", "library.item.rror_hub", base, 10),
                item("purple-hub", "library.item.purple_hub", base, 11),
                item("grayscale-hub", "library.item.grayscale_hub", base, 12),
                item("les-tueurs-d-eris-hub", "library.item.les_tueurs_d_eris_hub", base, 13),
                item("h-e-r-operation-hub", "library.item.h_e_r_operation_hub", base, 14),
                item("quartet-hub", "library.item.quartet_hub", base, 15),
                item("humankind-hub", "library.item.humankind_hub", base, 16),
                item("foundation-detective-hub", "library.item.foundation_detective_hub", base, 17),
                item("yidan-hub", "library.item.yidan_hub", base, 18),
                item("critics-hub", "library.item.critics_hub", base, 19),
                item("why-did-they-say-its-a-beautiful-day-in-the-quiet-world-hub", "library.item.why_quiet_world_hub", base, 20),
                item("miyazawakenji-hub", "library.item.miyazawakenji_hub", base, 21),
                item("myo-rei-ji", "library.item.myo_rei_ji", base, 22),
                item("doden", "library.item.doden", base, 23),
                item("oblivion-adium", "library.item.oblivion_adium", base, 24),
                item("q9alt-hub", "library.item.q9alt_hub", base, 25),
                item("jin-you-hub", "library.item.jin_you_hub", base, 26),
                item("out-of-scp-universe-hub", "library.item.out_of_scp_universe_hub", base, 27),
                item("kamiyotsugi-hub", "library.item.kamiyotsugi_hub", base, 28),
                item("foundation-arbeiter-hub", "library.item.foundation_arbeiter_hub", base, 29),
                item("d-is-not-for-hub", "library.item.d_is_not_for_hub", base, 30),
                item("seiten-hub", "library.item.seiten_hub", base, 31),
                item("matchmaking2020", "library.item.matchmaking2020", base, 32),
                item("1998-911-hub", "library.item.1998_911_hub", base, 33),
                item("seikuken-hub", "library.item.seikuken_hub", base, 34),
                item("widely-containment-cases-hub", "library.item.widely_containment_cases_hub", base, 35),
                item("foundation-radio-bureau-hub", "library.item.foundation_radio_bureau_hub", base, 36),
                item("darum-tracer-hub", "library.item.darum_tracer_hub", base, 37),
                item("undertokyo-hub", "library.item.undertokyo_hub", base, 38)
            ]
        }
    }

    /// 英語メインサイト：要注意団体の代表的ハブ（`groups-of-interest` および主要団体ページ）。
    private static func englishGoIItems() -> [LibraryItem] {
        let base = URL(string: "https://scp-wiki.wikidot.com/")!
        let rows: [(String, String)] = [
            ("groups-of-interest", LocalizationKey.libraryItemGoIHubMasterEN),
            ("alexylva-university-hub", LocalizationKey.goiIndexHubAlexylva),
            ("ambrose-restaurant-hub", LocalizationKey.goiIndexHubAmbrose),
            ("anderson-robotics-hub", LocalizationKey.goiIndexHubAnderson),
            ("arcadia-hub", LocalizationKey.goiIndexHubArcadia),
            ("are-we-cool-yet-hub", LocalizationKey.goiIndexHubAWCY),
            ("black-queen-hub", LocalizationKey.goiIndexHubBlackQueen),
            ("chaos-insurgency-hub", LocalizationKey.goiIndexHubCI),
            ("chicago-spirit", LocalizationKey.goiIndexHubChicago),
            ("church-of-the-broken-god-hub", LocalizationKey.goiIndexHubCotBG),
            ("second-hytoth-hub", LocalizationKey.goiIndexHubCotSH),
            ("deer-college-hub", LocalizationKey.goiIndexHubDeer),
            ("factory-hub", LocalizationKey.goiIndexHubFactory),
            ("fifthist-hub", LocalizationKey.goiIndexHubFifthist),
            ("global-occult-coalition-hub", LocalizationKey.goiIndexHubGOC),
            ("gru-p-hub", LocalizationKey.goiIndexHubGruP),
            ("herman-fuller-hub", LocalizationKey.goiIndexHubHermanFuller),
            ("horizon-initiative-hub", LocalizationKey.goiIndexHubHI),
            ("ijamea-hub", LocalizationKey.goiIndexHubIJAMEA),
            ("manna-charitable-foundation-hub", LocalizationKey.goiIndexHubMCF),
            ("marshall-carter-and-dark-hub", LocalizationKey.goiIndexHubMCD),
            ("nobody-hub", LocalizationKey.goiIndexHubNobody),
            ("oria-hub", LocalizationKey.goiIndexHubORIA),
            ("oneiroi", LocalizationKey.goiIndexHubOneiroi),
            ("parawatch-hub", LocalizationKey.goiIndexHubParawatch),
            ("prometheus-labs-hub", LocalizationKey.goiIndexHubPrometheus),
            ("serpent-s-hand-hub", LocalizationKey.goiIndexHubSH),
            ("spc-hub", LocalizationKey.goiIndexHubSPC),
            ("three-moons-initiative-hub", LocalizationKey.goiIndexHubTMI),
            ("unusual-incidents-unit-hub", LocalizationKey.goiIndexHubUIU),
            ("wandsmen-hub", LocalizationKey.goiIndexHubW),
            ("wilson-s-wildlife-solutions-hub", LocalizationKey.goiIndexHubWWS)
        ]
        var order = 1
        var items: [LibraryItem] = []
        for (path, key) in rows {
            items.append(
                LibraryItem(
                    id: path,
                    titleLocalizationKey: key,
                    title: nil,
                    url: base.appendingPathComponent(path),
                    wikiCreationOrder: order,
                    primaryAuthorSortKey: ""
                )
            )
            order += 1
        }
        return items
    }

    private static func item(
        _ path: String,
        _ titleKey: String,
        _ base: URL,
        _ wikiCreationOrder: Int,
        _ primaryAuthorSortKey: String = ""
    ) -> LibraryItem {
        let url = base.appendingPathComponent(path)
        return LibraryItem(
            id: path,
            titleLocalizationKey: titleKey,
            title: nil,
            url: url,
            wikiCreationOrder: wikiCreationOrder,
            primaryAuthorSortKey: primaryAuthorSortKey
        )
    }
}
