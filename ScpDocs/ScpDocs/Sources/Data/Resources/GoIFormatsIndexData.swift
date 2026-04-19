import Foundation

/// `goi-formats-jp` ページの目次・各要注意団体のハブ（`Research/html_goi-jp.txt`）に準拠。
enum GoIFormatsIndexData: Sendable {
    private static let jpBase = URL(string: "https://scp-jp.wikidot.com/")!

    struct IndexLink: Identifiable, Hashable, Sendable {
        let id: String
        let titleLocalizationKey: String
        let url: URL
    }

    /// ページ冒頭の案内リンク。
    static let portals: [IndexLink] = [
        IndexLink(
            id: "portal_goi_jp",
            titleLocalizationKey: LocalizationKey.goiIndexPortalGoiMasterJP,
            url: jpBase.appendingPathComponent("groups-of-interest-jp")
        ),
        IndexLink(
            id: "portal_goi_formats_en",
            titleLocalizationKey: LocalizationKey.goiIndexPortalGoiFormatsEN,
            url: jpBase.appendingPathComponent("goi-formats")
        ),
        IndexLink(
            id: "portal_intl",
            titleLocalizationKey: LocalizationKey.goiIndexPortalInternationalFormats,
            url: jpBase.appendingPathComponent("international-goi-formats")
        )
    ]

    /// 「要注意団体-EN」見出し直下のハブ（h2 の `a[href]` 順）。
    static let englishFormatHubs: [IndexLink] = {
        let paths: [(String, String)] = [
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
            ("goc-hub-page", LocalizationKey.goiIndexHubGOC),
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
        return paths.map { path, key in
            IndexLink(id: path, titleLocalizationKey: key, url: jpBase.appendingPathComponent(path))
        }
    }()

    /// 「要注意団体-JP」見出し下。ハブ無しの団体は `goi-formats-jp` 内アンカーへ。
    static let japanFormatHubs: [IndexLink] = {
        var items: [IndexLink] = []
        func hub(_ path: String, _ key: String) {
            items.append(IndexLink(id: path, titleLocalizationKey: key, url: jpBase.appendingPathComponent(path)))
        }
        func anchor(_ name: String, _ key: String) {
            var c = URLComponents(url: jpBase.appendingPathComponent("goi-formats-jp"), resolvingAgainstBaseURL: false)!
            c.fragment = name
            items.append(IndexLink(id: "goi-formats-jp#\(name)", titleLocalizationKey: key, url: c.url!))
        }

        hub("aodaisho-hub", LocalizationKey.goiIndexHubAodaisho)
        hub("pamwac-hub", LocalizationKey.goiIndexHubPAMWAC)
        anchor("imaginanimal", LocalizationKey.goiIndexHubImaginanimal)
        hub("elma-hub", LocalizationKey.goiIndexHubElma)
        anchor("tokuzika", LocalizationKey.goiIndexHubTokuzika)
        anchor("koigarezaki", LocalizationKey.goiIndexHubKoigarezaki)
        anchor("saigaha", LocalizationKey.goiIndexHubSaigaha)
        anchor("shushuin", LocalizationKey.goiIndexHubShushuin)
        anchor("sekiryuclub", LocalizationKey.goiIndexHubSekiryuClub)
        hub("toyoho-hub", LocalizationKey.goiIndexHubTono)
        hub("joicle-catalog-hub", LocalizationKey.goiIndexHubJOICLE)
        hub("jagpato-hub", LocalizationKey.goiIndexHubJAGPATO)
        anchor("meiteigai", LocalizationKey.goiIndexHubMeiteigai)
        hub("mujin-getsudo-hub", LocalizationKey.goiIndexHubMujinGetsudo)
        hub("yamizushi-hub", LocalizationKey.goiIndexHubYamizushi)
        anchor("yumemi", LocalizationKey.goiIndexHubYumemi)
        return items
    }()
}
