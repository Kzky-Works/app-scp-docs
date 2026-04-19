import Foundation

/// `goi-formats-jp` の団体別ハブと GoI フォーマット記事（Research/html_scp-goi-jp.txt から生成）。
enum GoILibraryHierarchyData: Sendable {
    struct Article: Identifiable, Hashable, Sendable {
        let id: String
        let title: String
        let url: URL
    }

    struct Group: Identifiable, Sendable {
        let id: String
        let hubTitle: String
        /// 団体ハブ。`nil` のときは `goi-formats-jp` のアンカーのみ等で Web のみ参照。
        let hubURL: URL?
        let articles: [Article]
    }

    /// 日本支部 `goi-formats-jp` 本文に相当する団体ブロック（ハブ URL + 子記事）。
    static let japanGoIFormatGroups: [Group] = [
        Group(
            id: "alexylva_alexylva-university-hub_0",
            hubTitle: "Alexylva大学",
            hubURL: URL(string: "https://scp-jp.wikidot.com/alexylva-university-hub")!,
            articles: [
            ]
        ),
        Group(
            id: "ambrose_ambrose-restaurant-hub_1",
            hubTitle: "アンブローズ・レストラン",
            hubURL: URL(string: "https://scp-jp.wikidot.com/ambrose-restaurant-hub")!,
            articles: [
                Article(
                    id: "ambrose_ambrose-restaurant-hub_1_a0",
                    title: "アンブローズ・シガスタン",
                    url: URL(string: "https://scp-jp.wikidot.com/ambrose-shigastan")!
                ),
                Article(
                    id: "ambrose_ambrose-restaurant-hub_1_a1",
                    title: "アンブローズ・山猫軒",
                    url: URL(string: "https://scp-jp.wikidot.com/ambrose-wildcat-house")!
                ),
                Article(
                    id: "ambrose_ambrose-restaurant-hub_1_a2",
                    title: "アンブローズ・世界の終わり",
                    url: URL(string: "https://scp-jp.wikidot.com/ambrose-the-end-of-the-world")!
                ),
                Article(
                    id: "ambrose_ambrose-restaurant-hub_1_a3",
                    title: "アンブローズ・壊れたる食卓",
                    url: URL(string: "https://scp-jp.wikidot.com/ambrose-on-the-gears")!
                ),
                Article(
                    id: "ambrose_ambrose-restaurant-hub_1_a4",
                    title: "料理亭・あんぶろうず・灰殻",
                    url: URL(string: "https://scp-jp.wikidot.com/restaurant-ambrose-haikara")!
                ),
                Article(
                    id: "ambrose_ambrose-restaurant-hub_1_a5",
                    title: "アンブローズ茶屋・伏見 醍醐の花見のご案内",
                    url: URL(string: "https://scp-jp.wikidot.com/ambrose-cafe-fushimi-invitation-to-daigo-no-hanami")!
                ),
                Article(
                    id: "ambrose_ambrose-restaurant-hub_1_a6",
                    title: "安歩路家",
                    url: URL(string: "https://scp-jp.wikidot.com/ambrose-ullambana")!
                ),
            ]
        ),
        Group(
            id: "anderson_anderson-robotics-hub_2",
            hubTitle: "アンダーソン・ロボティクス",
            hubURL: URL(string: "https://scp-jp.wikidot.com/anderson-robotics-hub")!,
            articles: [
                Article(
                    id: "anderson_anderson-robotics-hub_2_a0",
                    title: "アンダーソン・ロボティクス・インストール・ガイド: アクイラ-アダルベルティ・シリーズ強化外骨格スーツ！",
                    url: URL(string: "https://scp-jp.wikidot.com/aquila-adalberti-series-mechanical-exoskeleton")!
                ),
                Article(
                    id: "anderson_anderson-robotics-hub_2_a1",
                    title: "アンダーソン・ロボティクス・インストール・ガイド: アルバシラ・シリーズ体感時間調整インプラント！",
                    url: URL(string: "https://scp-jp.wikidot.com/albicilla-series-implant")!
                ),
            ]
        ),
        Group(
            id: "arcadia_arcadia-hub_3",
            hubTitle: "アルカディア",
            hubURL: URL(string: "https://scp-jp.wikidot.com/arcadia-hub")!,
            articles: [
                Article(
                    id: "arcadia_arcadia-hub_3_a0",
                    title: "DEAL(ディール) ストアページ",
                    url: URL(string: "https://scp-jp.wikidot.com/deal-storepage")!
                ),
            ]
        ),
        Group(
            id: "awcy_are-we-cool-yet-hub_4",
            hubTitle: "Are We Cool Yet?",
            hubURL: URL(string: "https://scp-jp.wikidot.com/are-we-cool-yet-hub")!,
            articles: [
                Article(
                    id: "awcy_are-we-cool-yet-hub_4_a0",
                    title: "企画案2019-0401：“安眠”",
                    url: URL(string: "https://scp-jp.wikidot.com/project-proposal-2019-0401-cool-night")!
                ),
                Article(
                    id: "awcy_are-we-cool-yet-hub_4_a1",
                    title: "企画案2014-226：“色のない迷路”(凍結)",
                    url: URL(string: "https://scp-jp.wikidot.com/project-proposal-2014-226-archived")!
                ),
                Article(
                    id: "awcy_are-we-cool-yet-hub_4_a2",
                    title: "企画案2004-567: “無名の墓碑”",
                    url: URL(string: "https://scp-jp.wikidot.com/project-proposal-2004-567")!
                ),
                Article(
                    id: "awcy_are-we-cool-yet-hub_4_a3",
                    title: "企画案2014-512(仮): &quot;パンドーラーの声&quot;",
                    url: URL(string: "https://scp-jp.wikidot.com/project-proposal-2014-512")!
                ),
                Article(
                    id: "awcy_are-we-cool-yet-hub_4_a4",
                    title: "企画案2020-998: &quot;雌牛の医者&quot;",
                    url: URL(string: "https://scp-jp.wikidot.com/project-proposal-2020-998")!
                ),
                Article(
                    id: "awcy_are-we-cool-yet-hub_4_a5",
                    title: "企画案2044-664: &quot;宇宙壁紙&quot;",
                    url: URL(string: "https://scp-jp.wikidot.com/project-proposal-2044-664")!
                ),
                Article(
                    id: "awcy_are-we-cool-yet-hub_4_a6",
                    title: "企画案2024-001: &quot;夜明け前の星&quot;",
                    url: URL(string: "https://scp-jp.wikidot.com/project-proposal-2024-001")!
                ),
                Article(
                    id: "awcy_are-we-cool-yet-hub_4_a7",
                    title: "企画案2024-998: &quot;信仰は何の為に&quot;",
                    url: URL(string: "https://scp-jp.wikidot.com/project-proposal-2024-998")!
                ),
                Article(
                    id: "awcy_are-we-cool-yet-hub_4_a8",
                    title: "企画案2022-387: &quot;ただ貴方の為に咲く&quot;",
                    url: URL(string: "https://scp-jp.wikidot.com/project-proposal-2022-387")!
                ),
                Article(
                    id: "awcy_are-we-cool-yet-hub_4_a9",
                    title: "企画案2024-003: “全世界的オイディプス、もしくは「ガイアファック」”",
                    url: URL(string: "https://scp-jp.wikidot.com/project-proposal-2024-003")!
                ),
                Article(
                    id: "awcy_are-we-cool-yet-hub_4_a10",
                    title: "企画案2024-429: &quot;私という遺作&quot;",
                    url: URL(string: "https://scp-jp.wikidot.com/project-proposal-2024-429")!
                ),
                Article(
                    id: "awcy_are-we-cool-yet-hub_4_a11",
                    title: "企画案2024-898:”爆発は芸術だ”",
                    url: URL(string: "https://scp-jp.wikidot.com/project-proposal-2024-898-jp")!
                ),
                Article(
                    id: "awcy_are-we-cool-yet-hub_4_a12",
                    title: "企画案2024-701: &quot;クールの灯明&quot;",
                    url: URL(string: "https://scp-jp.wikidot.com/project-proposal-2024-701")!
                ),
                Article(
                    id: "awcy_are-we-cool-yet-hub_4_a13",
                    title: "企画案2024-529: &quot;美への羽ばたき&quot;",
                    url: URL(string: "https://scp-jp.wikidot.com/project-proposal-2024-529")!
                ),
                Article(
                    id: "awcy_are-we-cool-yet-hub_4_a14",
                    title: "企画案2024-013: &quot;合祀の再誕&quot;",
                    url: URL(string: "https://scp-jp.wikidot.com/project-proposal-2024-013")!
                ),
                Article(
                    id: "awcy_are-we-cool-yet-hub_4_a15",
                    title: "企画案2024-159: &quot;死因放送&quot;",
                    url: URL(string: "https://scp-jp.wikidot.com/project-proposal-2024-159")!
                ),
                Article(
                    id: "awcy_are-we-cool-yet-hub_4_a16",
                    title: "企画案2044-004: &quot;不朽の牢獄&quot;",
                    url: URL(string: "https://scp-jp.wikidot.com/project-proposal-2044-004")!
                ),
            ]
        ),
        Group(
            id: "blackqueen_black-queen-hub_5",
            hubTitle: "黒の女王",
            hubURL: URL(string: "https://scp-jp.wikidot.com/black-queen-hub")!,
            articles: [
                Article(
                    id: "blackqueen_black-queen-hub_5_a0",
                    title: "アハシマ",
                    url: URL(string: "https://scp-jp.wikidot.com/ahashima")!
                ),
                Article(
                    id: "blackqueen_black-queen-hub_5_a1",
                    title: "エリス",
                    url: URL(string: "https://scp-jp.wikidot.com/eris")!
                ),
                Article(
                    id: "blackqueen_black-queen-hub_5_a2",
                    title: "カワウソのアヒージョ",
                    url: URL(string: "https://scp-jp.wikidot.com/otter-al-ajillo")!
                ),
                Article(
                    id: "blackqueen_black-queen-hub_5_a3",
                    title: "近畿ファミレス殺人事件",
                    url: URL(string: "https://scp-jp.wikidot.com/murder-at-the-restaurant-in-kinki")!
                ),
                Article(
                    id: "blackqueen_black-queen-hub_5_a4",
                    title: "グラビタス・グラダリス",
                    url: URL(string: "https://scp-jp.wikidot.com/gravitas-gradalis")!
                ),
                Article(
                    id: "blackqueen_black-queen-hub_5_a5",
                    title: "黒の群臣",
                    url: URL(string: "https://scp-jp.wikidot.com/black-vassal")!
                ),
                Article(
                    id: "blackqueen_black-queen-hub_5_a6",
                    title: "Saiga",
                    url: URL(string: "https://scp-jp.wikidot.com/saiga")!
                ),
                Article(
                    id: "blackqueen_black-queen-hub_5_a7",
                    title: "サルモン",
                    url: URL(string: "https://scp-jp.wikidot.com/salomon")!
                ),
                Article(
                    id: "blackqueen_black-queen-hub_5_a8",
                    title: "収束の星冠",
                    url: URL(string: "https://scp-jp.wikidot.com/starry-crown-popped")!
                ),
                Article(
                    id: "blackqueen_black-queen-hub_5_a9",
                    title: "タカオ",
                    url: URL(string: "https://scp-jp.wikidot.com/takao")!
                ),
                Article(
                    id: "blackqueen_black-queen-hub_5_a10",
                    title: "商人の三宅",
                    url: URL(string: "https://scp-jp.wikidot.com/miyake")!
                ),
                Article(
                    id: "blackqueen_black-queen-hub_5_a11",
                    title: "日暮れのような夜明けを",
                    url: URL(string: "https://scp-jp.wikidot.com/daybreak-like-nightfall")!
                ),
                Article(
                    id: "blackqueen_black-queen-hub_5_a12",
                    title: "広末孝行",
                    url: URL(string: "https://scp-jp.wikidot.com/hirosuetakayuki")!
                ),
                Article(
                    id: "blackqueen_black-queen-hub_5_a13",
                    title: "ヘルメス",
                    url: URL(string: "https://scp-jp.wikidot.com/hermes")!
                ),
                Article(
                    id: "blackqueen_black-queen-hub_5_a14",
                    title: "ぼっちのジョージ",
                    url: URL(string: "https://scp-jp.wikidot.com/lonesome-george")!
                ),
                Article(
                    id: "blackqueen_black-queen-hub_5_a15",
                    title: "眼鏡の女神",
                    url: URL(string: "https://scp-jp.wikidot.com/goddess-of-glasses")!
                ),
                Article(
                    id: "blackqueen_black-queen-hub_5_a16",
                    title: "幽霊の標識",
                    url: URL(string: "https://scp-jp.wikidot.com/ghost-sign")!
                ),
                Article(
                    id: "blackqueen_black-queen-hub_5_a17",
                    title: "鼓動の時計",
                    url: URL(string: "https://scp-jp.wikidot.com/times-of-day")!
                ),
                Article(
                    id: "blackqueen_black-queen-hub_5_a18",
                    title: "ファム・ファタール",
                    url: URL(string: "https://scp-jp.wikidot.com/femme-fatale")!
                ),
                Article(
                    id: "blackqueen_black-queen-hub_5_a19",
                    title: "ミズ・K-クラス",
                    url: URL(string: "https://scp-jp.wikidot.com/ms-k-class")!
                ),
                Article(
                    id: "blackqueen_black-queen-hub_5_a20",
                    title: "健康のおまじない",
                    url: URL(string: "https://scp-jp.wikidot.com/health-cantrip")!
                ),
                Article(
                    id: "blackqueen_black-queen-hub_5_a21",
                    title: "再生部門(マナ財団じゃない方の)",
                    url: URL(string: "https://scp-jp.wikidot.com/department-of-reconstruction-not-mcf")!
                ),
                Article(
                    id: "blackqueen_black-queen-hub_5_a22",
                    title: "真桑友梨佳の提言",
                    url: URL(string: "https://scp-jp.wikidot.com/makuwayurika-s-proposal")!
                ),
                Article(
                    id: "blackqueen_black-queen-hub_5_a23",
                    title: "Organizal",
                    url: URL(string: "https://scp-jp.wikidot.com/organizal")!
                ),
                Article(
                    id: "blackqueen_black-queen-hub_5_a24",
                    title: "洒脱、散髪、美容室",
                    url: URL(string: "https://scp-jp.wikidot.com/elegant-haircut")!
                ),
                Article(
                    id: "blackqueen_black-queen-hub_5_a25",
                    title: "Who is the killer？",
                    url: URL(string: "https://scp-jp.wikidot.com/who-is-the-killer")!
                ),
                Article(
                    id: "blackqueen_black-queen-hub_5_a26",
                    title: "イリスのノート",
                    url: URL(string: "https://scp-jp.wikidot.com/twin-notebook")!
                ),
                Article(
                    id: "blackqueen_black-queen-hub_5_a27",
                    title: "ネコモドキダニを用いたノネコ駆除計画",
                    url: URL(string: "https://scp-jp.wikidot.com/control-plan-for-feral-cat")!
                ),
                Article(
                    id: "blackqueen_black-queen-hub_5_a28",
                    title: "会議は踊る、されど……",
                    url: URL(string: "https://scp-jp.wikidot.com/der-kongress-tanzt")!
                ),
            ]
        ),
        Group(
            id: "ci_chaos-insurgency-hub_6",
            hubTitle: "カオス・インサージェンシー",
            hubURL: URL(string: "https://scp-jp.wikidot.com/chaos-insurgency-hub")!,
            articles: [
                Article(
                    id: "ci_chaos-insurgency-hub_6_a0",
                    title: "SC-99/734-01/506",
                    url: URL(string: "https://scp-jp.wikidot.com/sc-99-734-01-506")!
                ),
                Article(
                    id: "ci_chaos-insurgency-hub_6_a1",
                    title: "SC-19/122-14/073-JP",
                    url: URL(string: "https://scp-jp.wikidot.com/sc-19-122-14-073-jp")!
                ),
            ]
        ),
        Group(
            id: "chicago_chicago-spirit_7",
            hubTitle: "シカゴ・スピリット",
            hubURL: URL(string: "https://scp-jp.wikidot.com/chicago-spirit")!,
            articles: [
                Article(
                    id: "chicago_chicago-spirit_7_a0",
                    title: "キャロル#291: 依代",
                    url: URL(string: "https://scp-jp.wikidot.com/the-bloody-doll")!
                ),
                Article(
                    id: "chicago_chicago-spirit_7_a1",
                    title: "キャロル#427: 嘆き屋",
                    url: URL(string: "https://scp-jp.wikidot.com/the-mourner")!
                ),
                Article(
                    id: "chicago_chicago-spirit_7_a2",
                    title: "キャロル#014: 奇跡殺しの刃",
                    url: URL(string: "https://scp-jp.wikidot.com/the-thaumatokill-knife")!
                ),
            ]
        ),
        Group(
            id: "cotbg_church-of-the-broken-god-hub_8",
            hubTitle: "壊れた神の教会",
            hubURL: URL(string: "https://scp-jp.wikidot.com/church-of-the-broken-god-hub")!,
            articles: [
            ]
        ),
        Group(
            id: "cotsh_second-hytoth-hub_9",
            hubTitle: "第二ハイトス教会",
            hubURL: URL(string: "https://scp-jp.wikidot.com/second-hytoth-hub")!,
            articles: [
            ]
        ),
        Group(
            id: "deer_deer-college-hub_10",
            hubTitle: "ディア大学",
            hubURL: URL(string: "https://scp-jp.wikidot.com/deer-college-hub")!,
            articles: [
                Article(
                    id: "deer_deer-college-hub_10_a0",
                    title: "4月のならず者たち",
                    url: URL(string: "https://scp-jp.wikidot.com/rogues-of-the-april-deer")!
                ),
                Article(
                    id: "deer_deer-college-hub_10_a1",
                    title: "ディア大学の新興宗教",
                    url: URL(string: "https://scp-jp.wikidot.com/new-religion-of-deer-college")!
                ),
            ]
        ),
        Group(
            id: "factory_factory-hub_11",
            hubTitle: "ザ・ファクトリー",
            hubURL: URL(string: "https://scp-jp.wikidot.com/factory-hub")!,
            articles: [
                Article(
                    id: "factory_factory-hub_11_a0",
                    title: "連鎖崩壊 (C-12213)",
                    url: URL(string: "https://scp-jp.wikidot.com/chain-collapse-12213")!
                ),
            ]
        ),
        Group(
            id: "fifthism_fifthist-hub_12",
            hubTitle: "第五教会",
            hubURL: URL(string: "https://scp-jp.wikidot.com/fifthist-hub")!,
            articles: [
                Article(
                    id: "fifthism_fifthist-hub_12_a0",
                    title: "闇寿司ファイルNo.555 &quot;トラック#55： Can You Feel？ / 君は感じる？&quot;",
                    url: URL(string: "https://scp-jp.wikidot.com/can-you-feel-yamizushi-file-555")!
                ),
                Article(
                    id: "fifthism_fifthist-hub_12_a1",
                    title: "メモ ::: 何一つ問題はなくなる",
                    url: URL(string: "https://scp-jp.wikidot.com/ethic")!
                ),
            ]
        ),
        Group(
            id: "goc_goc-hub-page_13",
            hubTitle: "世界オカルト連合(GOC)",
            hubURL: URL(string: "https://scp-jp.wikidot.com/goc-hub-page")!,
            articles: [
                Article(
                    id: "goc_goc-hub-page_13_a0",
                    title: "LTE-5230-Fiji-Aurora Cherry",
                    url: URL(string: "https://scp-jp.wikidot.com/lte-5230-fiji-aurora-cherry")!
                ),
                Article(
                    id: "goc_goc-hub-page_13_a1",
                    title: "KTE-1505-Corona",
                    url: URL(string: "https://scp-jp.wikidot.com/kte-1505-corona")!
                ),
                Article(
                    id: "goc_goc-hub-page_13_a2",
                    title: "PTE-1422-Bosch-L'Engle",
                    url: URL(string: "https://scp-jp.wikidot.com/pte-1422-bosch-lengle")!
                ),
                Article(
                    id: "goc_goc-hub-page_13_a3",
                    title: "KTE-0934-Einherjar-Goodrickchild",
                    url: URL(string: "https://scp-jp.wikidot.com/kte-0934-einherjar-goodrickchild")!
                ),
                Article(
                    id: "goc_goc-hub-page_13_a4",
                    title: "LTE-9202-Blue-Blackbuster",
                    url: URL(string: "https://scp-jp.wikidot.com/lte-9202-blue-blackbuster")!
                ),
                Article(
                    id: "goc_goc-hub-page_13_a5",
                    title: "LTE-5481-Cyan-Typhon",
                    url: URL(string: "https://scp-jp.wikidot.com/lte-5481-cyan-typhon")!
                ),
            ]
        ),
        Group(
            id: "gru-p_gru-p-hub_14",
            hubTitle: "ロシア連邦軍参謀本部情報総局&quot;P&quot;部局",
            hubURL: URL(string: "https://scp-jp.wikidot.com/gru-p-hub")!,
            articles: [
            ]
        ),
        Group(
            id: "hermanfuller_herman-fuller-hub_15",
            hubTitle: "ハーマン・フラーの不気味サーカス",
            hubURL: URL(string: "https://scp-jp.wikidot.com/herman-fuller-hub")!,
            articles: [
                Article(
                    id: "hermanfuller_herman-fuller-hub_15_a0",
                    title: "ハーマン・フラー主催: 「女の死」と「奇跡の誕生」",
                    url: URL(string: "https://scp-jp.wikidot.com/the-birth-of-a-miracle")!
                ),
                Article(
                    id: "hermanfuller_herman-fuller-hub_15_a1",
                    title: "ハーマン・フラー主催: キネマのサムライ",
                    url: URL(string: "https://scp-jp.wikidot.com/the-samurai-of-kinema")!
                ),
                Article(
                    id: "hermanfuller_herman-fuller-hub_15_a2",
                    title: "ハーマン・フラー主催: サグラダファミリア料理対決",
                    url: URL(string: "https://scp-jp.wikidot.com/the-cooking-battle-of-sagradafamilia")!
                ),
                Article(
                    id: "hermanfuller_herman-fuller-hub_15_a3",
                    title: "ハーマン・フラー主催: 光の天使サニー",
                    url: URL(string: "https://scp-jp.wikidot.com/the-angel-of-light-sunny")!
                ),
            ]
        ),
        Group(
            id: "hi_horizon-initiative-hub_16",
            hubTitle: "境界線イニシアチブ",
            hubURL: URL(string: "https://scp-jp.wikidot.com/horizon-initiative-hub")!,
            articles: [
                Article(
                    id: "hi_horizon-initiative-hub_16_a0",
                    title: "銃を繕う",
                    url: URL(string: "https://scp-jp.wikidot.com/repairing-a-gun")!
                ),
            ]
        ),
        Group(
            id: "ijamea_ijamea-hub_17",
            hubTitle: "大日本帝国異常事例調査局(IJAMEA)",
            hubURL: URL(string: "https://scp-jp.wikidot.com/ijamea-hub")!,
            articles: [
                Article(
                    id: "ijamea_ijamea-hub_17_a0",
                    title: "燎原計画、昭和一七年",
                    url: URL(string: "https://scp-jp.wikidot.com/ryogen")!
                ),
                Article(
                    id: "ijamea_ijamea-hub_17_a1",
                    title: "シンコンサン計画, 2020",
                    url: URL(string: "https://scp-jp.wikidot.com/project-shinkon-san-2020")!
                ),
                Article(
                    id: "ijamea_ijamea-hub_17_a2",
                    title: "錦ノ御旗計画、昭和一七年",
                    url: URL(string: "https://scp-jp.wikidot.com/project-nishiki-no-mihata-1942")!
                ),
                Article(
                    id: "ijamea_ijamea-hub_17_a3",
                    title: "GoGoGo!And Go's On!",
                    url: URL(string: "https://scp-jp.wikidot.com/go-go-go-and-gos-on")!
                ),
                Article(
                    id: "ijamea_ijamea-hub_17_a4",
                    title: "八重垣計画、昭和八年",
                    url: URL(string: "https://scp-jp.wikidot.com/project-yaegaki-1933")!
                ),
            ]
        ),
        Group(
            id: "mcf_manna-charitable-foundation-hub_18",
            hubTitle: "マナによる慈善財団",
            hubURL: URL(string: "https://scp-jp.wikidot.com/manna-charitable-foundation-hub")!,
            articles: [
                Article(
                    id: "mcf_manna-charitable-foundation-hub_18_a0",
                    title: "日本生類創研第四寄贈品",
                    url: URL(string: "https://scp-jp.wikidot.com/fourth-joicle-donation")!
                ),
                Article(
                    id: "mcf_manna-charitable-foundation-hub_18_a1",
                    title: "プロジェクト･エチオピア",
                    url: URL(string: "https://scp-jp.wikidot.com/project-ethiopia")!
                ),
                Article(
                    id: "mcf_manna-charitable-foundation-hub_18_a2",
                    title: "ハセガワ製薬第一寄贈品",
                    url: URL(string: "https://scp-jp.wikidot.com/first-hasegawa-pharmaceutical-donation")!
                ),
            ]
        ),
        Group(
            id: "mcd_marshall-carter-and-dark-hub_19",
            hubTitle: "マーシャル・カーター＆ダーク株式会社",
            hubURL: URL(string: "https://scp-jp.wikidot.com/marshall-carter-and-dark-hub")!,
            articles: [
                Article(
                    id: "mcd_marshall-carter-and-dark-hub_19_a0",
                    title: "'ブルドッグの首輪' (FRI23/RIW32/89H91)",
                    url: URL(string: "https://scp-jp.wikidot.com/bulldog-s-collar")!
                ),
                Article(
                    id: "mcd_marshall-carter-and-dark-hub_19_a1",
                    title: "’安全次元移動装置’(F3L57/HJ754/3W43G)",
                    url: URL(string: "https://scp-jp.wikidot.com/safe-dimension")!
                ),
                Article(
                    id: "mcd_marshall-carter-and-dark-hub_19_a2",
                    title: "'フーヴァーズ' (J362N/E43D7/29HV9)",
                    url: URL(string: "https://scp-jp.wikidot.com/mcd-hoovers")!
                ),
                Article(
                    id: "mcd_marshall-carter-and-dark-hub_19_a3",
                    title: "'ボーラス&amp;ブロックの亡霊鎖' (PV723/AYR28/SB376)",
                    url: URL(string: "https://scp-jp.wikidot.com/ghost-chain-pv723-ayr28-sb376")!
                ),
            ]
        ),
        Group(
            id: "nobody_nobody-hub_20",
            hubTitle: "「何者でもない」",
            hubURL: URL(string: "https://scp-jp.wikidot.com/nobody-hub")!,
            articles: [
                Article(
                    id: "nobody_nobody-hub_20_a0",
                    title: "メモ: どこでもない海",
                    url: URL(string: "https://scp-jp.wikidot.com/note-the-ocean-of-nowhere")!
                ),
                Article(
                    id: "nobody_nobody-hub_20_a1",
                    title: "メモ: 渡しそびれてる手紙",
                    url: URL(string: "http://scp-jp.wikidot.com/note-unhanded-letter")!
                ),
                Article(
                    id: "nobody_nobody-hub_20_a2",
                    title: "メモ: 何者も逃れられない",
                    url: URL(string: "http://scp-jp.wikidot.com/note-why-japanese-people")!
                ),
                Article(
                    id: "nobody_nobody-hub_20_a3",
                    title: "メモ: 他愛ないことなど",
                    url: URL(string: "http://scp-jp.wikidot.com/note-trivial-things")!
                ),
                Article(
                    id: "nobody_nobody-hub_20_a4",
                    title: "メモ: ペトリコールで思い出した事",
                    url: URL(string: "https://scp-jp.wikidot.com/memories-of-petrichor")!
                ),
                Article(
                    id: "nobody_nobody-hub_20_a5",
                    title: "メモ: 凍り付いたパソコン",
                    url: URL(string: "https://scp-jp.wikidot.com/note-freeze-notepc")!
                ),
                Article(
                    id: "nobody_nobody-hub_20_a6",
                    title: "メモ: 自分探し",
                    url: URL(string: "https://scp-jp.wikidot.com/note-find-myself")!
                ),
                Article(
                    id: "nobody_nobody-hub_20_a7",
                    title: "メモ: エレベーターの怪人",
                    url: URL(string: "https://scp-jp.wikidot.com/note-phantom-of-elevator")!
                ),
                Article(
                    id: "nobody_nobody-hub_20_a8",
                    title: "メモ: Second Shell",
                    url: URL(string: "https://scp-jp.wikidot.com/memories-of-secondshell")!
                ),
                Article(
                    id: "nobody_nobody-hub_20_a9",
                    title: "メモ: 一本の竿",
                    url: URL(string: "https://scp-jp.wikidot.com/note-one-rod")!
                ),
            ]
        ),
        Group(
            id: "oria_oria-hub_21",
            hubTitle: "イスラム・アーティファクト開発事務局(ORIA)",
            hubURL: URL(string: "https://scp-jp.wikidot.com/oria-hub")!,
            articles: [
                Article(
                    id: "oria_oria-hub_21_a0",
                    title: "覚書091 プロジェクト「隠遁」に関して",
                    url: URL(string: "https://scp-jp.wikidot.com/memorandum-091-regarding-project-asceticism")!
                ),
            ]
        ),
        Group(
            id: "oneiroi_oneiroi_22",
            hubTitle: "オネイロイ・コレクティブ",
            hubURL: URL(string: "https://scp-jp.wikidot.com/oneiroi")!,
            articles: [
                Article(
                    id: "oneiroi_oneiroi_22_a0",
                    title: "#アエリアナ",
                    url: URL(string: "https://scp-jp.wikidot.com/aeliana")!
                ),
                Article(
                    id: "oneiroi_oneiroi_22_a1",
                    title: "育つ子は寝る",
                    url: URL(string: "https://scp-jp.wikidot.com/sleeping-students")!
                ),
                Article(
                    id: "oneiroi_oneiroi_22_a2",
                    title: "アーキタイプ・エンジン",
                    url: URL(string: "https://scp-jp.wikidot.com/archetype-engine")!
                ),
                Article(
                    id: "oneiroi_oneiroi_22_a3",
                    title: "#マウソロス",
                    url: URL(string: "https://scp-jp.wikidot.com/mausolus")!
                ),
                Article(
                    id: "oneiroi_oneiroi_22_a4",
                    title: "悪夢の淵からの目覚め",
                    url: URL(string: "https://scp-jp.wikidot.com/wake-up-from-the-nightmare")!
                ),
                Article(
                    id: "oneiroi_oneiroi_22_a5",
                    title: "#クォルタリア",
                    url: URL(string: "https://scp-jp.wikidot.com/qortalia")!
                ),
                Article(
                    id: "oneiroi_oneiroi_22_a6",
                    title: "オネイロイ・カードゲーム",
                    url: URL(string: "https://scp-jp.wikidot.com/oneiroi-card-game")!
                ),
                Article(
                    id: "oneiroi_oneiroi_22_a7",
                    title: "忍者のエゴサーチ",
                    url: URL(string: "https://scp-jp.wikidot.com/ninja-egosearching")!
                ),
                Article(
                    id: "oneiroi_oneiroi_22_a8",
                    title: "ファン・アンド・ファンシー・フリー",
                    url: URL(string: "https://scp-jp.wikidot.com/fun-and-fancy-free")!
                ),
                Article(
                    id: "oneiroi_oneiroi_22_a9",
                    title: "#シナリオライター求ム",
                    url: URL(string: "https://scp-jp.wikidot.com/lost-techno-logic")!
                ),
                Article(
                    id: "oneiroi_oneiroi_22_a10",
                    title: "そして夢骸は夜明けとともに",
                    url: URL(string: "https://scp-jp.wikidot.com/corpse-night-dream")!
                ),
                Article(
                    id: "oneiroi_oneiroi_22_a11",
                    title: "どうして僕たちは生まれて来れなかったの？",
                    url: URL(string: "https://scp-jp.wikidot.com/why-were-not-we-born")!
                ),
                Article(
                    id: "oneiroi_oneiroi_22_a12",
                    title: "夢路に迷える宝物",
                    url: URL(string: "https://scp-jp.wikidot.com/treasures-lost-in-dreamroad")!
                ),
                Article(
                    id: "oneiroi_oneiroi_22_a13",
                    title: "バンクシー",
                    url: URL(string: "https://scp-jp.wikidot.com/fake-banksy")!
                ),
                Article(
                    id: "oneiroi_oneiroi_22_a14",
                    title: "立て続けに起こされて",
                    url: URL(string: "https://scp-jp.wikidot.com/snooze-in-a-row")!
                ),
            ]
        ),
        Group(
            id: "paraw_parawatch-hub_23",
            hubTitle: "パラウォッチ",
            hubURL: URL(string: "https://scp-jp.wikidot.com/parawatch-hub")!,
            articles: [
                Article(
                    id: "paraw_parawatch-hub_23_a0",
                    title: "真夏の冬将軍",
                    url: URL(string: "https://scp-jp.wikidot.com/midsummer-ded-moroz")!
                ),
                Article(
                    id: "paraw_parawatch-hub_23_a1",
                    title: "うんちなげごりら",
                    url: URL(string: "https://scp-jp.wikidot.com/gorilla-throwing-poop")!
                ),
                Article(
                    id: "paraw_parawatch-hub_23_a2",
                    title: "季節外れのホトトギス",
                    url: URL(string: "https://scp-jp.wikidot.com/unseasonable-lesser-cuckoo")!
                ),
                Article(
                    id: "paraw_parawatch-hub_23_a3",
                    title: "セントマイヤーズ号遭難事故",
                    url: URL(string: "https://scp-jp.wikidot.com/centmayears-vessel")!
                ),
                Article(
                    id: "paraw_parawatch-hub_23_a4",
                    title: "ルロウマ",
                    url: URL(string: "https://scp-jp.wikidot.com/ruroumaru")!
                ),
            ]
        ),
        Group(
            id: "plabs_prometheus-labs-hub_24",
            hubTitle: "株式会社プロメテウス研究所",
            hubURL: URL(string: "https://scp-jp.wikidot.com/prometheus-labs-hub")!,
            articles: [
                Article(
                    id: "plabs_prometheus-labs-hub_24_a0",
                    title: "小規模な霊力発電機の建造のための認可計画",
                    url: URL(string: "https://scp-jp.wikidot.com/grant-request-for-the-construction-of-a-small-psychoelectric")!
                ),
                Article(
                    id: "plabs_prometheus-labs-hub_24_a1",
                    title: "自己複製装置を用いた小惑星からの採掘のための認可計画",
                    url: URL(string: "https://scp-jp.wikidot.com/grant-request-for-the-mining-from-asteroids")!
                ),
                Article(
                    id: "plabs_prometheus-labs-hub_24_a2",
                    title: "レイライン流路改善を実行する電気奇跡論コンピュータシステムの試作のための認可計画",
                    url: URL(string: "https://scp-jp.wikidot.com/grant-request-for-experiment-of-improvement-of-ley-line")!
                ),
                Article(
                    id: "plabs_prometheus-labs-hub_24_a3",
                    title: "テレキル合金を応用した奇跡論阻害効果を持つ新素材のための認可計画",
                    url: URL(string: "https://scp-jp.wikidot.com/grant-request-for-the-telekinetic-alloy")!
                ),
                Article(
                    id: "plabs_prometheus-labs-hub_24_a4",
                    title: "急速な人口増加を補助する育成・教育設備の開発のための認可計画",
                    url: URL(string: "https://scp-jp.wikidot.com/grant-request-for-development-of-nurturing-and-education")!
                ),
                Article(
                    id: "plabs_prometheus-labs-hub_24_a5",
                    title: "神聖祈念弾頭を搭載可能な大型ヒューマノイドロボット開発のための認可計画",
                    url: URL(string: "https://scp-jp.wikidot.com/grant-request-for-the-g-development-project")!
                ),
                Article(
                    id: "plabs_prometheus-labs-hub_24_a6",
                    title: "超小型自己複製装置を用いた限定的空間を対象とする現実性供給システムのための認可計画",
                    url: URL(string: "https://scp-jp.wikidot.com/grant-request-for-the-system-of-hume-supply-by-nanomachine")!
                ),
                Article(
                    id: "plabs_prometheus-labs-hub_24_a7",
                    title: "特殊性を要する計画の秘匿を目的とした本社ビルディングの異時空間移設及び閉鎖学術研究都市建設のための認可計画",
                    url: URL(string: "https://scp-jp.wikidot.com/grant-request-for-the-kingdom-of-prometheus")!
                ),
                Article(
                    id: "plabs_prometheus-labs-hub_24_a8",
                    title: "地下東京における人工太陽製造のための認可計画(第88稿)",
                    url: URL(string: "http://scp-jp.wikidot.com/grant-request-for-the-underground-artificial-sun")!
                ),
                Article(
                    id: "plabs_prometheus-labs-hub_24_a9",
                    title: "特定の人員要件緩和手段としての心象概念調整機材開発の為の認可計画",
                    url: URL(string: "http://scp-jp.wikidot.com/grant-request-for-development-of-awareness-coordination")!
                ),
            ]
        ),
        Group(
            id: "sh_serpent-s-hand-hub_25",
            hubTitle: "蛇の手",
            hubURL: URL(string: "https://scp-jp.wikidot.com/serpent-s-hand-hub")!,
            articles: [
                Article(
                    id: "sh_serpent-s-hand-hub_25_a0",
                    title: "極東地域の伝統的な決闘様式",
                    url: URL(string: "https://scp-jp.wikidot.com/the-spinners")!
                ),
                Article(
                    id: "sh_serpent-s-hand-hub_25_a1",
                    title: "逸脱の民を討て",
                    url: URL(string: "https://scp-jp.wikidot.com/the-deviationers")!
                ),
                Article(
                    id: "sh_serpent-s-hand-hub_25_a2",
                    title: "ミッション: インビジブル",
                    url: URL(string: "https://scp-jp.wikidot.com/the-infiltrators")!
                ),
                Article(
                    id: "sh_serpent-s-hand-hub_25_a3",
                    title: "夜明けを見るための絶対条件",
                    url: URL(string: "https://scp-jp.wikidot.com/absolute-requirement-for-dawn")!
                ),
                Article(
                    id: "sh_serpent-s-hand-hub_25_a4",
                    title: "蛇は光を見ず 闇を見ず ただ熱を見て這い進む",
                    url: URL(string: "https://scp-jp.wikidot.com/the-pit-viper")!
                ),
            ]
        ),
        Group(
            id: "spc_spc-hub_26",
            hubTitle: "サメ殴りセンター",
            hubURL: URL(string: "https://scp-jp.wikidot.com/spc-hub")!,
            articles: [
                Article(
                    id: "spc_spc-hub_26_a0",
                    title: "SPC-001-JP",
                    url: URL(string: "https://scp-jp.wikidot.com/spc-001-jp")!
                ),
                Article(
                    id: "spc_spc-hub_26_a1",
                    title: "indonootokoの提言Ⅱ...きっとね。",
                    url: URL(string: "https://scp-jp.wikidot.com/indonootoko-proposal-ii-spc")!
                ),
                Article(
                    id: "spc_spc-hub_26_a2",
                    title: "Fennecistの妄言",
                    url: URL(string: "https://scp-jp.wikidot.com/fennecist-proposal-spc")!
                ),
                Article(
                    id: "spc_spc-hub_26_a3",
                    title: "時絡の寝言‥‥むにゃむにゃ。",
                    url: URL(string: "https://scp-jp.wikidot.com/jiraku-mogana-proposal-spc")!
                ),
                Article(
                    id: "spc_spc-hub_26_a4",
                    title: "𨭆の提言",
                    url: URL(string: "https://scp-jp.wikidot.com/108hassium-proposal-spc")!
                ),
                Article(
                    id: "spc_spc-hub_26_a5",
                    title: "インドマンIV=DJ･カクタスの提言",
                    url: URL(string: "https://scp-jp.wikidot.com/spc-2022-jp")!
                ),
                Article(
                    id: "spc_spc-hub_26_a6",
                    title: "SPC-002-JP",
                    url: URL(string: "https://scp-jp.wikidot.com/spc-002-jp")!
                ),
                Article(
                    id: "spc_spc-hub_26_a7",
                    title: "SPC-034-JP",
                    url: URL(string: "https://scp-jp.wikidot.com/spc-034-jp")!
                ),
                Article(
                    id: "spc_spc-hub_26_a8",
                    title: "SPC-040-JP",
                    url: URL(string: "https://scp-jp.wikidot.com/spc-040-jp")!
                ),
                Article(
                    id: "spc_spc-hub_26_a9",
                    title: "SPC-183-JP",
                    url: URL(string: "https://scp-jp.wikidot.com/spc-183-jp")!
                ),
                Article(
                    id: "spc_spc-hub_26_a10",
                    title: "SPC-287-JP-KO-J",
                    url: URL(string: "https://scp-jp.wikidot.com/spc-287-jp-ko-j")!
                ),
                Article(
                    id: "spc_spc-hub_26_a11",
                    title: "SPC-489-JP",
                    url: URL(string: "https://scp-jp.wikidot.com/spc-489-jp-j")!
                ),
                Article(
                    id: "spc_spc-hub_26_a12",
                    title: "SPC-796-JP",
                    url: URL(string: "https://scp-jp.wikidot.com/spc-796-jp")!
                ),
                Article(
                    id: "spc_spc-hub_26_a13",
                    title: "SPC-1485",
                    url: URL(string: "https://scp-jp.wikidot.com/spc-1485-jp")!
                ),
                Article(
                    id: "spc_spc-hub_26_a14",
                    title: "SPC-1666-JP",
                    url: URL(string: "https://scp-jp.wikidot.com/spc-1666-jp")!
                ),
                Article(
                    id: "spc_spc-hub_26_a15",
                    title: "SPC-1710-JP",
                    url: URL(string: "https://scp-jp.wikidot.com/spc-1710-jp")!
                ),
                Article(
                    id: "spc_spc-hub_26_a16",
                    title: "SPC-1824-JP",
                    url: URL(string: "https://scp-jp.wikidot.com/spc-1824-jp")!
                ),
                Article(
                    id: "spc_spc-hub_26_a17",
                    title: "SPC-2000-JP",
                    url: URL(string: "https://scp-jp.wikidot.com/spc-2000-jp")!
                ),
                Article(
                    id: "spc_spc-hub_26_a18",
                    title: "SPC-2019-JP",
                    url: URL(string: "https://scp-jp.wikidot.com/spc-2019-jp-af2019")!
                ),
                Article(
                    id: "spc_spc-hub_26_a19",
                    title: "SPC-CN-2021",
                    url: URL(string: "https://scp-jp.wikidot.com/spc-cn-2021")!
                ),
                Article(
                    id: "spc_spc-hub_26_a20",
                    title: "SPC-2999-JP（暫定的）",
                    url: URL(string: "https://scp-jp.wikidot.com/spc-2999-jp")!
                ),
                Article(
                    id: "spc_spc-hub_26_a21",
                    title: "SPC-3316-JP",
                    url: URL(string: "https://scp-jp.wikidot.com/spc-3316-jp")!
                ),
            ]
        ),
        Group(
            id: "tmi_three-moons-initiative-hub_27",
            hubTitle: "三ツ月イニシアチブ",
            hubURL: URL(string: "https://scp-jp.wikidot.com/three-moons-initiative-hub")!,
            articles: [
            ]
        ),
        Group(
            id: "uiu_unusual-incidents-unit-hub_28",
            hubTitle: "連邦捜査局(FBI)異常事件課(UIU)",
            hubURL: URL(string: "https://scp-jp.wikidot.com/unusual-incidents-unit-hub")!,
            articles: [
                Article(
                    id: "uiu_unusual-incidents-unit-hub_28_a0",
                    title: "UIUファイル: 1999-074",
                    url: URL(string: "https://scp-jp.wikidot.com/uiu-file-1999-074")!
                ),
                Article(
                    id: "uiu_unusual-incidents-unit-hub_28_a1",
                    title: "UIUファイル: 2001-745",
                    url: URL(string: "https://scp-jp.wikidot.com/uiu-file-2001-745")!
                ),
                Article(
                    id: "uiu_unusual-incidents-unit-hub_28_a2",
                    title: "UIUファイル: 2011-119",
                    url: URL(string: "https://scp-jp.wikidot.com/uiu-file-2011-119")!
                ),
            ]
        ),
        Group(
            id: "w_wandsmen-hub_29",
            hubTitle: "堂守連盟",
            hubURL: URL(string: "https://scp-jp.wikidot.com/wandsmen-hub")!,
            articles: [
                Article(
                    id: "w_wandsmen-hub_29_a0",
                    title: "プログレスの予兆",
                    url: URL(string: "https://scp-jp.wikidot.com/signs-of-progress")!
                ),
            ]
        ),
        Group(
            id: "wws_wilson-s-wildlife-solutions-hub_30",
            hubTitle: "ウィルソンズ・ワイルドライフ・ソリューションズ",
            hubURL: URL(string: "https://scp-jp.wikidot.com/wilson-s-wildlife-solutions-hub")!,
            articles: [
                Article(
                    id: "wws_wilson-s-wildlife-solutions-hub_30_a0",
                    title: "生き物？プロフィール: クレイシー！",
                    url: URL(string: "https://scp-jp.wikidot.com/critter-profile-claycy")!
                ),
                Article(
                    id: "wws_wilson-s-wildlife-solutions-hub_30_a1",
                    title: "生き物プロフィール: シガスタン！",
                    url: URL(string: "https://scp-jp.wikidot.com/critter-profile-shigastan")!
                ),
                Article(
                    id: "wws_wilson-s-wildlife-solutions-hub_30_a2",
                    title: "生き物プロフィール: アーサー！",
                    url: URL(string: "https://scp-jp.wikidot.com/critter-profile-arthur-jp")!
                ),
                Article(
                    id: "wws_wilson-s-wildlife-solutions-hub_30_a3",
                    title: "生き物プロフィール: ブルンゴ！",
                    url: URL(string: "https://scp-jp.wikidot.com/critter-profile-brungo")!
                ),
                Article(
                    id: "wws_wilson-s-wildlife-solutions-hub_30_a4",
                    title: "生き物プロフィール: ファッキンクソダック！",
                    url: URL(string: "https://scp-jp.wikidot.com/critter-profile-nikolai")!
                ),
                Article(
                    id: "wws_wilson-s-wildlife-solutions-hub_30_a5",
                    title: "生き物プロフィール: ミラベル！",
                    url: URL(string: "https://scp-jp.wikidot.com/critter-profile-mirabel")!
                ),
                Article(
                    id: "wws_wilson-s-wildlife-solutions-hub_30_a6",
                    title: "生き物プロフィール: ガルーダ！",
                    url: URL(string: "https://scp-jp.wikidot.com/critter-profile-garuda")!
                ),
                Article(
                    id: "wws_wilson-s-wildlife-solutions-hub_30_a7",
                    title: "生き物プロフィール: オーウェン！",
                    url: URL(string: "https://scp-jp.wikidot.com/critter-profile-owen")!
                ),
                Article(
                    id: "wws_wilson-s-wildlife-solutions-hub_30_a8",
                    title: "生き物プロフィール: ルーナ！",
                    url: URL(string: "https://scp-jp.wikidot.com/critter-profile-luna")!
                ),
                Article(
                    id: "wws_wilson-s-wildlife-solutions-hub_30_a9",
                    title: "生き物プロフィール: ランディー！",
                    url: URL(string: "https://scp-jp.wikidot.com/critter-profile-randy")!
                ),
                Article(
                    id: "wws_wilson-s-wildlife-solutions-hub_30_a10",
                    title: "生き物プロフィール: ボック！",
                    url: URL(string: "https://scp-jp.wikidot.com/critter-profile-bock")!
                ),
                Article(
                    id: "wws_wilson-s-wildlife-solutions-hub_30_a11",
                    title: "生き物プロフィール: タンタタ！",
                    url: URL(string: "https://scp-jp.wikidot.com/critter-profile-tantata")!
                ),
                Article(
                    id: "wws_wilson-s-wildlife-solutions-hub_30_a12",
                    title: "生き物プロフィール: オリバー！",
                    url: URL(string: "https://scp-jp.wikidot.com/critter-profile-oliver")!
                ),
                Article(
                    id: "wws_wilson-s-wildlife-solutions-hub_30_a13",
                    title: "指名手配: マンタレイ海賊団！",
                    url: URL(string: "https://scp-jp.wikidot.com/wanted-mantaray-pirates")!
                ),
                Article(
                    id: "wws_wilson-s-wildlife-solutions-hub_30_a14",
                    title: "生き物プロフィール: ユニコ！",
                    url: URL(string: "https://scp-jp.wikidot.com/critter-profile-uniko")!
                ),
                Article(
                    id: "wws_wilson-s-wildlife-solutions-hub_30_a15",
                    title: "生き物プロフィール: ウィロウ！",
                    url: URL(string: "https://scp-jp.wikidot.com/critter-profile-willow")!
                ),
                Article(
                    id: "wws_wilson-s-wildlife-solutions-hub_30_a16",
                    title: "生き物プロフィール: オーノ！",
                    url: URL(string: "https://scp-jp.wikidot.com/critter-profile-ohno")!
                ),
                Article(
                    id: "wws_wilson-s-wildlife-solutions-hub_30_a17",
                    title: "居住者募集ポスター: ネイサンズ・ハウス！",
                    url: URL(string: "https://scp-jp.wikidot.com/resident-recruitment-poster-nathan-s-house")!
                ),
                Article(
                    id: "wws_wilson-s-wildlife-solutions-hub_30_a18",
                    title: "里親募集ポスター: マイロ！",
                    url: URL(string: "https://scp-jp.wikidot.com/adoption-poster-milo")!
                ),
                Article(
                    id: "wws_wilson-s-wildlife-solutions-hub_30_a19",
                    title: "生き物プロフィール: ヒロ！",
                    url: URL(string: "https://scp-jp.wikidot.com/critter-profile-hiro")!
                ),
                Article(
                    id: "wws_wilson-s-wildlife-solutions-hub_30_a20",
                    title: "生き物プロフィール: バルーン！",
                    url: URL(string: "https://scp-jp.wikidot.com/critter-profile-balloon")!
                ),
            ]
        ),
        Group(
            id: "other-goi_31",
            hubTitle: "その他/小規模な要注意団体",
            hubURL: URL(string: "https://scp-jp.wikidot.com/goi-formats-jp#other-goi")!,
            articles: [
                Article(
                    id: "other-goi_31_a0",
                    title: "ミルグラム忠誠度テスト",
                    url: URL(string: "https://scp-jp.wikidot.com/milgram-test")!
                ),
            ]
        ),
        Group(
            id: "aodaisho_aodaisho-hub_32",
            hubTitle: "青大将",
            hubURL: URL(string: "https://scp-jp.wikidot.com/aodaisho-hub")!,
            articles: [
                Article(
                    id: "aodaisho_aodaisho-hub_32_a0",
                    title: "秘匿輸送、釜山発遠野行",
                    url: URL(string: "https://scp-jp.wikidot.com/from-busan-to-tono-2020")!
                ),
                Article(
                    id: "aodaisho_aodaisho-hub_32_a1",
                    title: "日本岩手県のドリームランド",
                    url: URL(string: "https://scp-jp.wikidot.com/dreamlandiwate")!
                ),
                Article(
                    id: "aodaisho_aodaisho-hub_32_a2",
                    title: "竹槍三百万本論",
                    url: URL(string: "https://scp-jp.wikidot.com/surface-to-air-bamboo")!
                ),
                Article(
                    id: "aodaisho_aodaisho-hub_32_a3",
                    title: "概念の蛇が如何にしてあなた方と語らうことになったか",
                    url: URL(string: "https://scp-jp.wikidot.com/hello-i-am-an-nameless-aodaisho")!
                ),
            ]
        ),
        Group(
            id: "pamwac_pamwac-hub_33",
            hubTitle: "アニメキャラクターと結婚するための研究計画局(PAMWAC)",
            hubURL: URL(string: "https://scp-jp.wikidot.com/pamwac-hub")!,
            articles: [
                Article(
                    id: "pamwac_pamwac-hub_33_a0",
                    title: "狐娘目当てに妖怪保護区に行ったら大変な目にあった話",
                    url: URL(string: "https://scp-jp.wikidot.com/news4pamwac-fox")!
                ),
                Article(
                    id: "pamwac_pamwac-hub_33_a1",
                    title: "ワオ、色白美少女と結婚する方法をついに発見ｗｗｗｗｗｗｗｗｗ",
                    url: URL(string: "https://scp-jp.wikidot.com/news4pamwac-sadako")!
                ),
                Article(
                    id: "pamwac_pamwac-hub_33_a2",
                    title: "【金を】借金取りに追われてる足立区民ワイ、金の入手方求む。【くれ】",
                    url: URL(string: "https://scp-jp.wikidot.com/news4pamwac-money")!
                ),
                Article(
                    id: "pamwac_pamwac-hub_33_a3",
                    title: "ミーム嫁を語るスレ part3",
                    url: URL(string: "https://scp-jp.wikidot.com/news4pamwac-meme")!
                ),
                Article(
                    id: "pamwac_pamwac-hub_33_a4",
                    title: "俺の嫁を明日の秋天で走らせるスレ",
                    url: URL(string: "https://scp-jp.wikidot.com/news4pamwac-horse-racing")!
                ),
                Article(
                    id: "pamwac_pamwac-hub_33_a5",
                    title: "ワイ、創作美少女界の最高峰に挑む",
                    url: URL(string: "https://scp-jp.wikidot.com/news4pamwac-kaguya")!
                ),
                Article(
                    id: "pamwac_pamwac-hub_33_a6",
                    title: "ワア、二匹目のドジョウを狙うｗｗｗｗｗｗｗ",
                    url: URL(string: "https://scp-jp.wikidot.com/news4pamwac-youjo")!
                ),
                Article(
                    id: "pamwac_pamwac-hub_33_a7",
                    title: "人生で一番絶望する瞬間、コレに決定",
                    url: URL(string: "https://scp-jp.wikidot.com/news4pamwac-id-brightred")!
                ),
                Article(
                    id: "pamwac_pamwac-hub_33_a8",
                    title: "電子の妻を娶つたんだがね、訊きたい事はあるかい？",
                    url: URL(string: "https://scp-jp.wikidot.com/news4pamwac-digital")!
                ),
                Article(
                    id: "pamwac_pamwac-hub_33_a9",
                    title: "はっかきこ　ども",
                    url: URL(string: "https://scp-jp.wikidot.com/news4pamwac-yomeko")!
                ),
                Article(
                    id: "pamwac_pamwac-hub_33_a10",
                    title: "嫁と別れたことをここに告白します。",
                    url: URL(string: "https://scp-jp.wikidot.com/news4pamwac-pochi")!
                ),
                Article(
                    id: "pamwac_pamwac-hub_33_a11",
                    title: "嫁を人体錬成したら肉体失ったんだけど",
                    url: URL(string: "https://scp-jp.wikidot.com/news4pamwac-alchemist")!
                ),
                Article(
                    id: "pamwac_pamwac-hub_33_a12",
                    title: "神だけど質問ある？",
                    url: URL(string: "https://scp-jp.wikidot.com/news4pamwac-god")!
                ),
                Article(
                    id: "pamwac_pamwac-hub_33_a13",
                    title: "ワイがスーパーレスバマスターになった経緯wwwwww",
                    url: URL(string: "https://scp-jp.wikidot.com/news4pamwac-master-resuba")!
                ),
                Article(
                    id: "pamwac_pamwac-hub_33_a14",
                    title: "エルマ信徒だけど魔法少女と結婚する方法見つけたったｗｗｗ",
                    url: URL(string: "https://scp-jp.wikidot.com/news4pamwac-marry-me-magical-girl")!
                ),
                Article(
                    id: "pamwac_pamwac-hub_33_a15",
                    title: "もう俺が嫁になればいいんじゃね？",
                    url: URL(string: "https://scp-jp.wikidot.com/news4pamwac-iamyome")!
                ),
                Article(
                    id: "pamwac_pamwac-hub_33_a16",
                    title: "パムケに行こうとしたら&quot;組織&quot;の施設に飛ばされたんだが？？",
                    url: URL(string: "https://scp-jp.wikidot.com/news4pamwac-syuden5")!
                ),
                Article(
                    id: "pamwac_pamwac-hub_33_a17",
                    title: "ぼくは純粋な学術的興味から首絞めをしている。",
                    url: URL(string: "https://scp-jp.wikidot.com/news4pamwac-pamuboku")!
                ),
                Article(
                    id: "pamwac_pamwac-hub_33_a18",
                    title: "脱出神の最新作に没データを発見したのですが…",
                    url: URL(string: "https://scp-jp.wikidot.com/news4pamwac-escape-god")!
                ),
                Article(
                    id: "pamwac_pamwac-hub_33_a19",
                    title: "【2025年度】年度代表クソゲー決定会議 in PAMWAC part67【結果発表】",
                    url: URL(string: "https://scp-jp.wikidot.com/news4pamwac-koty")!
                ),
                Article(
                    id: "pamwac_pamwac-hub_33_a20",
                    title: "目が覚めると俺、知らない屋敷に閉じ込められてるんだが",
                    url: URL(string: "https://scp-jp.wikidot.com/pamsoku-this-is-creepy-pasta-3")!
                ),
                Article(
                    id: "pamwac_pamwac-hub_33_a21",
                    title: "嫁寿司 - PAMWACWiki(仮)",
                    url: URL(string: "https://scp-jp.wikidot.com/pamwacwiki-yomezushi")!
                ),
            ]
        ),
        Group(
            id: "imaginanimal_34",
            hubTitle: "Imaginanimal",
            hubURL: URL(string: "https://scp-jp.wikidot.com/goi-formats-jp#imaginanimal")!,
            articles: [
                Article(
                    id: "imaginanimal_34_a0",
                    title: "ぼくらのプロフィール: チベスナ…？",
                    url: URL(string: "https://scp-jp.wikidot.com/konkonkon")!
                ),
                Article(
                    id: "imaginanimal_34_a1",
                    title: "ディスコ・キラー・クラブの知名度向上を目的とした、ディスコ・キラー・クラブのImaginanimalによるディスコ・キラー・クラブの使い方エッセイ",
                    url: URL(string: "https://scp-jp.wikidot.com/dkcdkcdkc")!
                ),
                Article(
                    id: "imaginanimal_34_a2",
                    title: "い-A-6636 &quot;想見ダイレクト&quot;販売カタログ",
                    url: URL(string: "https://scp-jp.wikidot.com/i-a-6636-i-a-6636-i-a-6636")!
                ),
                Article(
                    id: "imaginanimal_34_a3",
                    title: "ぼくらのプロフィール: ティモール=ワニ！？",
                    url: URL(string: "https://scp-jp.wikidot.com/teximowa-moruwa")!
                ),
                Article(
                    id: "imaginanimal_34_a4",
                    title: "ニンゲン諸君に告ぐ！",
                    url: URL(string: "https://scp-jp.wikidot.com/harukiharukiharuki")!
                ),
            ]
        ),
        Group(
            id: "elma_elma-hub_35",
            hubTitle: "エルマ外教",
            hubURL: URL(string: "https://scp-jp.wikidot.com/elma-hub")!,
            articles: [
                Article(
                    id: "elma_elma-hub_35_a0",
                    title: "異世界跳躍先候補:001 &quot;アトラル&quot;",
                    url: URL(string: "https://scp-jp.wikidot.com/eden-leap-001")!
                ),
                Article(
                    id: "elma_elma-hub_35_a1",
                    title: "異世界跳躍先候補:117 &quot;ハーレット&quot;",
                    url: URL(string: "https://scp-jp.wikidot.com/eden-leap-117")!
                ),
                Article(
                    id: "elma_elma-hub_35_a2",
                    title: "異世界跳躍先候補:261 &quot;エピゴーネン牧草地&quot;",
                    url: URL(string: "https://scp-jp.wikidot.com/eden-leap-261")!
                ),
                Article(
                    id: "elma_elma-hub_35_a3",
                    title: "異世界跳躍先候補:353 &quot;母なる大地ボイザコン&quot;",
                    url: URL(string: "https://scp-jp.wikidot.com/eden-leap-353")!
                ),
                Article(
                    id: "elma_elma-hub_35_a4",
                    title: "異世界跳躍先候補:411 &quot;宇宙船神殺し号&quot;",
                    url: URL(string: "https://scp-jp.wikidot.com/eden-leap-411")!
                ),
                Article(
                    id: "elma_elma-hub_35_a5",
                    title: "異世界跳躍先候補:412 &quot;虹光池ジーヴスエト&quot;",
                    url: URL(string: "https://scp-jp.wikidot.com/eden-leap-412")!
                ),
                Article(
                    id: "elma_elma-hub_35_a6",
                    title: "異世界跳躍先候補:586 &quot;アルモネアの胃袋&quot;",
                    url: URL(string: "https://scp-jp.wikidot.com/eden-leap-586")!
                ),
                Article(
                    id: "elma_elma-hub_35_a7",
                    title: "異世界跳躍先候補:607 &quot;天文台エヴォリィーナ&quot;",
                    url: URL(string: "https://scp-jp.wikidot.com/eden-leap-607")!
                ),
                Article(
                    id: "elma_elma-hub_35_a8",
                    title: "異世界跳躍先候補:769 &quot;廃棄星オスティ=ルゥトピワ&quot;",
                    url: URL(string: "https://scp-jp.wikidot.com/eden-leap-769")!
                ),
                Article(
                    id: "elma_elma-hub_35_a9",
                    title: "異世界跳躍先候補:2773 &quot;テールース&quot;",
                    url: URL(string: "https://scp-jp.wikidot.com/eden-leap-2773")!
                ),
                Article(
                    id: "elma_elma-hub_35_a10",
                    title: "異世界跳躍先候補:1887 &quot;惑星ショグニス&quot;",
                    url: URL(string: "https://scp-jp.wikidot.com/eden-leap-1887")!
                ),
                Article(
                    id: "elma_elma-hub_35_a11",
                    title: "異世界跳躍先候補:2903 &quot;酔い潰れる地サティベックス&quot;",
                    url: URL(string: "https://scp-jp.wikidot.com/eden-leap-2903")!
                ),
                Article(
                    id: "elma_elma-hub_35_a12",
                    title: "異世界跳躍先候補:3131 &quot;ナイト・ミンミン&quot;",
                    url: URL(string: "https://scp-jp.wikidot.com/eden-leap-3131")!
                ),
                Article(
                    id: "elma_elma-hub_35_a13",
                    title: "異世界跳躍先候補:058-T-JP &quot;地獄&quot;",
                    url: URL(string: "https://scp-jp.wikidot.com/eden-leap-058-t-jp")!
                ),
                Article(
                    id: "elma_elma-hub_35_a14",
                    title: "終焉観測: 21813",
                    url: URL(string: "https://scp-jp.wikidot.com/end-watch-21813")!
                ),
                Article(
                    id: "elma_elma-hub_35_a15",
                    title: "終焉観測: 66212",
                    url: URL(string: "https://scp-jp.wikidot.com/end-watch-66212")!
                ),
                Article(
                    id: "elma_elma-hub_35_a16",
                    title: "終焉観測: 43722",
                    url: URL(string: "https://scp-jp.wikidot.com/end-watch-43722")!
                ),
                Article(
                    id: "elma_elma-hub_35_a17",
                    title: "終焉観測: 79458",
                    url: URL(string: "https://scp-jp.wikidot.com/end-watch-79458")!
                ),
            ]
        ),
        Group(
            id: "tokuzika_36",
            hubTitle: "警視庁公安部特事課",
            hubURL: URL(string: "https://scp-jp.wikidot.com/goi-formats-jp#tokuzika")!,
            articles: [
                Article(
                    id: "tokuzika_36_a0",
                    title: "国内特別関心領域: 遠野妖怪保護区",
                    url: URL(string: "https://scp-jp.wikidot.com/kanshin-ryoiki-tono")!
                ),
                Article(
                    id: "tokuzika_36_a1",
                    title: "国内特別関心領域: 恋昏崎",
                    url: URL(string: "https://scp-jp.wikidot.com/kanshin-ryoiki-koigarezaki")!
                ),
                Article(
                    id: "tokuzika_36_a2",
                    title: "大田区内未詳関心団体事業所膨張崩壊事件 第一次捜査報告書",
                    url: URL(string: "https://scp-jp.wikidot.com/record-reiwa-01-191")!
                ),
            ]
        ),
        Group(
            id: "koigarezaki_37",
            hubTitle: "恋昏崎新聞社",
            hubURL: URL(string: "https://scp-jp.wikidot.com/goi-formats-jp#koigarezaki")!,
            articles: [
                Article(
                    id: "koigarezaki_37_a0",
                    title: "エルマ転送艦A.L.I.C.E崩壊 行方不明者多数",
                    url: URL(string: "https://scp-jp.wikidot.com/koigarezaki-news-19951105")!
                ),
                Article(
                    id: "koigarezaki_37_a1",
                    title: "財団・GOC大失敗 南ポーランドが崩壊",
                    url: URL(string: "https://scp-jp.wikidot.com/koigarezaki-news-19980714-veil")!
                ),
                Article(
                    id: "koigarezaki_37_a2",
                    title: "マンハッタン次元崩落 GOC介入目前か",
                    url: URL(string: "https://scp-jp.wikidot.com/koigarezaki-news-911-1998-ver")!
                ),
                Article(
                    id: "koigarezaki_37_a3",
                    title: "財団 SCP-606-JP“拷問教会”の機密指定を解除",
                    url: URL(string: "https://scp-jp.wikidot.com/koigarezaki-news-20020228-1998ver")!
                ),
                Article(
                    id: "koigarezaki_37_a4",
                    title: "【独占インタビュー】狐也氏が語る韓国の現状　&quot;韓国革命&quot;はなぜ起こったのか",
                    url: URL(string: "https://scp-jp.wikidot.com/koigarezaki-news-20080103-1998ver")!
                ),
                Article(
                    id: "koigarezaki_37_a5",
                    title: "ORUCA運用開始から1年半 ICカード申請者数が目標を達成",
                    url: URL(string: "https://scp-jp.wikidot.com/koigarezaki-news-201x05-seikatsu")!
                ),
                Article(
                    id: "koigarezaki_37_a6",
                    title: "マンハッタンズ・メカニクスの左腕部　破壊される",
                    url: URL(string: "https://scp-jp.wikidot.com/koigarezaki-news-20150412-1998ver")!
                ),
                Article(
                    id: "koigarezaki_37_a7",
                    title: "IOCが組織委の要望を却下 揺れる東京五輪",
                    url: URL(string: "https://scp-jp.wikidot.com/koigarezaki-news-20160827")!
                ),
                Article(
                    id: "koigarezaki_37_a8",
                    title: "理外研電算機 身売りを含む選択肢を検討中か",
                    url: URL(string: "https://scp-jp.wikidot.com/koigarezaki-news-0517")!
                ),
                Article(
                    id: "koigarezaki_37_a9",
                    title: "首都圏特異集合事件から30年 怪異の今",
                    url: URL(string: "https://scp-jp.wikidot.com/koigarezaki-news-20170723")!
                ),
                Article(
                    id: "koigarezaki_37_a10",
                    title: "ハワイで海底遺跡発見　幻の島か",
                    url: URL(string: "https://scp-jp.wikidot.com/koigarezaki-news-20180803")!
                ),
                Article(
                    id: "koigarezaki_37_a11",
                    title: "財団の人体実験に児童参加か",
                    url: URL(string: "https://scp-jp.wikidot.com/koigarezaki-news-0130")!
                ),
                Article(
                    id: "koigarezaki_37_a12",
                    title: "財団9.11関与か 証拠映像入手",
                    url: URL(string: "https://scp-jp.wikidot.com/koigarezaki-news-911")!
                ),
                Article(
                    id: "koigarezaki_37_a13",
                    title: "NHK 超常社会との軋轢激化",
                    url: URL(string: "https://scp-jp.wikidot.com/koigarezaki-news-20190415")!
                ),
                Article(
                    id: "koigarezaki_37_a14",
                    title: "恋昏崎固有種の花 太古の地層より化石発見",
                    url: URL(string: "https://scp-jp.wikidot.com/koigarezaki-news-20190503")!
                ),
                Article(
                    id: "koigarezaki_37_a15",
                    title: "Xデー迫る 国内諸勢力の動き",
                    url: URL(string: "https://scp-jp.wikidot.com/koigarezaki-news-1224")!
                ),
                Article(
                    id: "koigarezaki_37_a16",
                    title: "スペイン政府 次元穴探検公社を設立",
                    url: URL(string: "https://scp-jp.wikidot.com/koigarezaki-news-20200602-1998ver")!
                ),
                Article(
                    id: "koigarezaki_37_a17",
                    title: "海面上昇から3か月 世界の現状は",
                    url: URL(string: "http://scp-jp.wikidot.com/koigarezaki-news-20200818-double-hometown-ver")!
                ),
                Article(
                    id: "koigarezaki_37_a18",
                    title: "信新告発文 現職知事に禁止米使用疑惑",
                    url: URL(string: "http://scp-jp.wikidot.com/koigarezaki-news-20200908")!
                ),
                Article(
                    id: "koigarezaki_37_a19",
                    title: "遠野妖怪保護区　大谷吉継氏（456）の入植を認可",
                    url: URL(string: "https://scp-jp.wikidot.com/koigarezaki-news-20210307")!
                ),
                Article(
                    id: "koigarezaki_37_a20",
                    title: "世界オカルト連合、麺類は実質寿司との見解 波紋広がる",
                    url: URL(string: "https://scp-jp.wikidot.com/koigarezaki-news-20210809")!
                ),
                Article(
                    id: "koigarezaki_37_a21",
                    title: "豊洲市場ス死のタナトマ事件 広がる波紋",
                    url: URL(string: "https://scp-jp.wikidot.com/koigarezaki-news-20220521-thanatomania-ver")!
                ),
                Article(
                    id: "koigarezaki_37_a22",
                    title: "財団給料未払い訴訟 初日が終了 東京地裁",
                    url: URL(string: "https://scp-jp.wikidot.com/koigarezaki-news-20220819-poorfoundation-ver")!
                ),
                Article(
                    id: "koigarezaki_37_a23",
                    title: "財団が突如創設100周年を発表 加速する歴史歪曲",
                    url: URL(string: "https://scp-jp.wikidot.com/koigarezaki-news-202300401")!
                ),
                Article(
                    id: "koigarezaki_37_a24",
                    title: "JASRAC 財団への仮処分を申立か",
                    url: URL(string: "https://scp-jp.wikidot.com/koigarezaki-news-20240316")!
                ),
                Article(
                    id: "koigarezaki_37_a25",
                    title: "強烈熱波が帰還シーズンを直撃 搬送多数",
                    url: URL(string: "https://scp-jp.wikidot.com/koigarezaki-news-veryhot")!
                ),
                Article(
                    id: "koigarezaki_37_a26",
                    title: "軽井沢女児行方不明事件から30年",
                    url: URL(string: "https://scp-jp.wikidot.com/koigarezaki-news-20240817")!
                ),
                Article(
                    id: "koigarezaki_37_a27",
                    title: "海中より謎の知的生命体上陸 住民騒然",
                    url: URL(string: "https://scp-jp.wikidot.com/koigarezaki-news-20240924")!
                ),
                Article(
                    id: "koigarezaki_37_a28",
                    title: "真桑事件 最高裁が死刑判決 被告側勝訴",
                    url: URL(string: "https://scp-jp.wikidot.com/koigarezaki-news-20241112")!
                ),
                Article(
                    id: "koigarezaki_37_a29",
                    title: "超電救助隊HEROレスキューチーム、解散へ",
                    url: URL(string: "https://scp-jp.wikidot.com/koigarezaki-news-20010825-1998-ver")!
                ),
                Article(
                    id: "koigarezaki_37_a30",
                    title: "サステナ仏法僧がエルマ外教本部に強襲 約1分で返り討ちに",
                    url: URL(string: "https://scp-jp.wikidot.com/koigarezaki-news-20260308")!
                ),
                Article(
                    id: "koigarezaki_37_a31",
                    title: "旋廻す奇怪なる壽司刄　廣末揆羅、妖邪の類用い激しく壽司囘轉さす術師に遭ふ 男「日奉 柏」と名乘りたり",
                    url: URL(string: "https://scp-jp.wikidot.com/holy-sushiblade")!
                ),
            ]
        ),
        Group(
            id: "saigaha_38",
            hubTitle: "犀賀派",
            hubURL: URL(string: "https://scp-jp.wikidot.com/goi-formats-jp#saigaha")!,
            articles: [
                Article(
                    id: "saigaha_38_a0",
                    title: "TFS-411",
                    url: URL(string: "https://scp-jp.wikidot.com/tfs-411")!
                ),
                Article(
                    id: "saigaha_38_a1",
                    title: "TFS-1391",
                    url: URL(string: "https://scp-jp.wikidot.com/tfs-1391")!
                ),
            ]
        ),
        Group(
            id: "shushuin_39",
            hubTitle: "蒐集院",
            hubURL: URL(string: "https://scp-jp.wikidot.com/goi-formats-jp#shushuin")!,
            articles: [
                Article(
                    id: "shushuin_39_a0",
                    title: "第〇〇〇八番",
                    url: URL(string: "https://scp-jp.wikidot.com/fragment:collected-item-no0008")!
                ),
                Article(
                    id: "shushuin_39_a1",
                    title: "第〇〇二五番",
                    url: URL(string: "https://scp-jp.wikidot.com/collected-item-no0025")!
                ),
                Article(
                    id: "shushuin_39_a2",
                    title: "第〇〇八六番",
                    url: URL(string: "https://scp-jp.wikidot.com/collected-item-no0086")!
                ),
                Article(
                    id: "shushuin_39_a3",
                    title: "第〇〇九一番",
                    url: URL(string: "https://scp-jp.wikidot.com/collected-item-no0091")!
                ),
                Article(
                    id: "shushuin_39_a4",
                    title: "第〇三二四番",
                    url: URL(string: "https://scp-jp.wikidot.com/collected-item-no0324")!
                ),
                Article(
                    id: "shushuin_39_a5",
                    title: "第〇七二三番",
                    url: URL(string: "https://scp-jp.wikidot.com/collected-item-no0723")!
                ),
                Article(
                    id: "shushuin_39_a6",
                    title: "第〇七二四番",
                    url: URL(string: "https://scp-jp.wikidot.com/collected-item-no0724")!
                ),
                Article(
                    id: "shushuin_39_a7",
                    title: "第〇七九八番",
                    url: URL(string: "https://scp-jp.wikidot.com/collected-item-no0798")!
                ),
                Article(
                    id: "shushuin_39_a8",
                    title: "第〇八四五番",
                    url: URL(string: "https://scp-jp.wikidot.com/collected-item-no0845")!
                ),
                Article(
                    id: "shushuin_39_a9",
                    title: "第〇九一四番",
                    url: URL(string: "https://scp-jp.wikidot.com/collected-item-no0914")!
                ),
                Article(
                    id: "shushuin_39_a10",
                    title: "第一〇八〇番",
                    url: URL(string: "https://scp-jp.wikidot.com/collected-item-no1080")!
                ),
                Article(
                    id: "shushuin_39_a11",
                    title: "第一〇九一番",
                    url: URL(string: "https://scp-jp.wikidot.com/collected-item-no1091")!
                ),
                Article(
                    id: "shushuin_39_a12",
                    title: "第一八七九番",
                    url: URL(string: "https://scp-jp.wikidot.com/collected-item-no1879")!
                ),
                Article(
                    id: "shushuin_39_a13",
                    title: "第二〇二〇番",
                    url: URL(string: "https://scp-jp.wikidot.com/collected-item-no2020")!
                ),
                Article(
                    id: "shushuin_39_a14",
                    title: "第二五二五番",
                    url: URL(string: "https://scp-jp.wikidot.com/collected-item-no2525")!
                ),
                Article(
                    id: "shushuin_39_a15",
                    title: "第三四三四番",
                    url: URL(string: "https://scp-jp.wikidot.com/collected-item-no3434")!
                ),
                Article(
                    id: "shushuin_39_a16",
                    title: "第一九三一六番",
                    url: URL(string: "https://scp-jp.wikidot.com/collected-item-no19316")!
                ),
            ]
        ),
        Group(
            id: "sekiryuclub_40",
            hubTitle: "石榴倶楽部",
            hubURL: URL(string: "https://scp-jp.wikidot.com/goi-formats-jp#sekiryuclub")!,
            articles: [
                Article(
                    id: "sekiryuclub_40_a0",
                    title: "亡姉の飢餓を想って",
                    url: URL(string: "https://scp-jp.wikidot.com/unfilled")!
                ),
                Article(
                    id: "sekiryuclub_40_a1",
                    title: "春秋の彩を添えて",
                    url: URL(string: "https://scp-jp.wikidot.com/autumn-leaves-and-peonies")!
                ),
                Article(
                    id: "sekiryuclub_40_a2",
                    title: "前橋詰 ██ ██氏のご逝去を悼む",
                    url: URL(string: "https://scp-jp.wikidot.com/mrhashidume-memorial")!
                ),
                Article(
                    id: "sekiryuclub_40_a3",
                    title: "新橋詰 ███ █氏を迎えて",
                    url: URL(string: "https://scp-jp.wikidot.com/mrhashidume-welcome")!
                ),
                Article(
                    id: "sekiryuclub_40_a4",
                    title: "人魚の祝宴",
                    url: URL(string: "https://scp-jp.wikidot.com/ningyo-no-syukuen")!
                ),
                Article(
                    id: "sekiryuclub_40_a5",
                    title: "██家御息女 薫子嬢の遺言と共に",
                    url: URL(string: "https://scp-jp.wikidot.com/misskaoruko-will")!
                ),
                Article(
                    id: "sekiryuclub_40_a6",
                    title: "新たな卸商を迎えて",
                    url: URL(string: "http://scp-jp.wikidot.com/ocular-pergola")!
                ),
            ]
        ),
        Group(
            id: "tono_toyoho-hub_41",
            hubTitle: "遠野妖怪保護区",
            hubURL: URL(string: "https://scp-jp.wikidot.com/toyoho-hub")!,
            articles: [
                Article(
                    id: "tono_toyoho-hub_41_a0",
                    title: "広報とよほ 2020年4月号 「夜行祭」ほか",
                    url: URL(string: "https://scp-jp.wikidot.com/toyoho-202004")!
                ),
                Article(
                    id: "tono_toyoho-hub_41_a1",
                    title: "広報とよほ 2024年1月号 「御座敷様のお引越し」ほか",
                    url: URL(string: "https://scp-jp.wikidot.com/toyoho-202401")!
                ),
                Article(
                    id: "tono_toyoho-hub_41_a2",
                    title: "広報とよほ 2024年11月号 「新銀河鉄道唱歌」ほか",
                    url: URL(string: "https://scp-jp.wikidot.com/toyoho-202411")!
                ),
                Article(
                    id: "tono_toyoho-hub_41_a3",
                    title: "遠野裏物語: 淵向こうの異人",
                    url: URL(string: "https://scp-jp.wikidot.com/tono-158")!
                ),
                Article(
                    id: "tono_toyoho-hub_41_a4",
                    title: "遠野裏物語: 渋谷ハロウィン事変",
                    url: URL(string: "https://scp-jp.wikidot.com/tono-1031")!
                ),
            ]
        ),
        Group(
            id: "JOICLE_42",
            hubTitle: "日本生類創研",
            hubURL: URL(string: "https://scp-jp.wikidot.com/goi-formats-jp#JOICLE")!,
            articles: [
                Article(
                    id: "JOICLE_42_a0",
                    title: "日本生類創研カタログ・ハブ",
                    url: URL(string: "https://scp-jp.wikidot.com/joicle-catalog-hub")!
                ),
                Article(
                    id: "JOICLE_42_a1",
                    title: "あ-A-0111 &quot;家庭用アダム&quot;販売カタログ",
                    url: URL(string: "https://scp-jp.wikidot.com/a-a-0111")!
                ),
                Article(
                    id: "JOICLE_42_a2",
                    title: "あ-N-0064 &quot;予言獣 クダン&quot;販売カタログ",
                    url: URL(string: "https://scp-jp.wikidot.com/a-n-0064")!
                ),
                Article(
                    id: "JOICLE_42_a3",
                    title: "う-M-2059&quot;スターゲイジーシード&quot;販売カタログ",
                    url: URL(string: "https://scp-jp.wikidot.com/u-m-2059")!
                ),
                Article(
                    id: "JOICLE_42_a4",
                    title: "う-S-0061 &quot;メロディアスラビット&quot;販売カタログ",
                    url: URL(string: "https://scp-jp.wikidot.com/u-s-0061")!
                ),
                Article(
                    id: "JOICLE_42_a5",
                    title: "う-Z-4000 &quot;ジンベイブレード&quot;販売カタログ",
                    url: URL(string: "https://scp-jp.wikidot.com/u-z-4000")!
                ),
                Article(
                    id: "JOICLE_42_a6",
                    title: "え-B-0551 &quot;タケトリロブスター&quot;販売カタログ",
                    url: URL(string: "https://scp-jp.wikidot.com/a-b-0551")!
                ),
                Article(
                    id: "JOICLE_42_a7",
                    title: "が-B-0134 &quot;ファーテリティ・ダウンフォール施術&quot;販売カタログ",
                    url: URL(string: "https://scp-jp.wikidot.com/g-b-0134")!
                ),
                Article(
                    id: "JOICLE_42_a8",
                    title: "が-B-0183&quot;リプロダクションライト&quot;販売カタログ",
                    url: URL(string: "https://scp-jp.wikidot.com/g-b-0183")!
                ),
                Article(
                    id: "JOICLE_42_a9",
                    title: "が-E-1370 &quot;外来生物捕食生物&quot;販売カタログ",
                    url: URL(string: "https://scp-jp.wikidot.com/g-e-1370")!
                ),
                Article(
                    id: "JOICLE_42_a10",
                    title: "が-E-2003 &quot;財団誘引生物&quot;販売カタログ",
                    url: URL(string: "https://scp-jp.wikidot.com/g-e-2003")!
                ),
                Article(
                    id: "JOICLE_42_a11",
                    title: "ぎ-A-2603 &quot;性格改変銃 パーティクル・ガン&quot;販売カタログ",
                    url: URL(string: "https://scp-jp.wikidot.com/g-e-2603")!
                ),
                Article(
                    id: "JOICLE_42_a12",
                    title: "き-D-6550 &quot;シャチクザウルス&quot;販売カタログ",
                    url: URL(string: "https://scp-jp.wikidot.com/k-d-6550")!
                ),
                Article(
                    id: "JOICLE_42_a13",
                    title: "く-S-0682 &quot;おりこうさんトカゲ&quot;販売カタログ",
                    url: URL(string: "https://scp-jp.wikidot.com/k-s-0682")!
                ),
                Article(
                    id: "JOICLE_42_a14",
                    title: "さ-A-6157&quot;シンバイオティクスタブレット&quot;販売カタログ",
                    url: URL(string: "https://scp-jp.wikidot.com/s-a-6157")!
                ),
                Article(
                    id: "JOICLE_42_a15",
                    title: "す-K-1300&quot;「ミエナクナール錠」&quot;販売カタログ",
                    url: URL(string: "https://scp-jp.wikidot.com/s-k-1300")!
                ),
                Article(
                    id: "JOICLE_42_a16",
                    title: "せ-B-1998&quot;セミバスターダケ&quot;販売カタログ",
                    url: URL(string: "https://scp-jp.wikidot.com/s-b-1998")!
                ),
                Article(
                    id: "JOICLE_42_a17",
                    title: "せ-G-1664&quot;共生自足米「やどりがみ」&quot;販売カタログ",
                    url: URL(string: "https://scp-jp.wikidot.com/s-g-1664")!
                ),
                Article(
                    id: "JOICLE_42_a18",
                    title: "な-A-1774 &quot;愛玩型同伴生物&quot;販売カタログ",
                    url: URL(string: "https://scp-jp.wikidot.com/n-a-1774")!
                ),
                Article(
                    id: "JOICLE_42_a19",
                    title: "な-A-2044 &quot;リビングキャット&quot;販売カタログ",
                    url: URL(string: "https://scp-jp.wikidot.com/n-a-2044")!
                ),
                Article(
                    id: "JOICLE_42_a20",
                    title: "な-A-2318 &quot;生命ダイナモ&quot;販売カタログ",
                    url: URL(string: "https://scp-jp.wikidot.com/n-a-2318")!
                ),
                Article(
                    id: "JOICLE_42_a21",
                    title: "な-R-0089&quot;ベビーコインロッカー&quot;販売カタログ",
                    url: URL(string: "https://scp-jp.wikidot.com/n-r-0089")!
                ),
                Article(
                    id: "JOICLE_42_a22",
                    title: "ぱ-B-4099 &quot;スマートニューロン&quot;販売カタログ",
                    url: URL(string: "https://scp-jp.wikidot.com/p-b-4099")!
                ),
                Article(
                    id: "JOICLE_42_a23",
                    title: "び-M-1034 &quot;シロウオスプラッシュ&quot;販売カタログ",
                    url: URL(string: "https://scp-jp.wikidot.com/b-m-1034")!
                ),
                Article(
                    id: "JOICLE_42_a24",
                    title: "ひ-P-801 &quot;ピグマリオン・スタチュー&quot;販売カタログ-電子版",
                    url: URL(string: "https://scp-jp.wikidot.com/h-p-0801")!
                ),
                Article(
                    id: "JOICLE_42_a25",
                    title: "ふ-A-1030&quot;クリーンフナムシ&quot;販売カタログ",
                    url: URL(string: "https://scp-jp.wikidot.com/f-a-1030")!
                ),
                Article(
                    id: "JOICLE_42_a26",
                    title: "ふ-T-2078 &quot;ブタのQちゃん&quot;販売カタログ",
                    url: URL(string: "https://scp-jp.wikidot.com/f-t-2078")!
                ),
                Article(
                    id: "JOICLE_42_a27",
                    title: "ほ-A-3001 &quot;ダイレクトホニャインコくん&quot;販売カタログ",
                    url: URL(string: "https://scp-jp.wikidot.com/h-a-3001")!
                ),
                Article(
                    id: "JOICLE_42_a28",
                    title: "む-A-2407&quot;「とわひかり」種籾&quot;販売カタログ",
                    url: URL(string: "https://scp-jp.wikidot.com/m-a-2407")!
                ),
                Article(
                    id: "JOICLE_42_a29",
                    title: "よ-B-035 &quot;霊銀式ヒューマノイド&quot;販売カタログ",
                    url: URL(string: "https://scp-jp.wikidot.com/y-b-0035")!
                ),
                Article(
                    id: "JOICLE_42_a30",
                    title: "ら-B-1177 &quot;ライフモデリング膣錠&quot;販売カタログ",
                    url: URL(string: "https://scp-jp.wikidot.com/r-b-1177")!
                ),
                Article(
                    id: "JOICLE_42_a31",
                    title: "ろ-A-552 優秀知能選別法 実験参加者募集",
                    url: URL(string: "https://scp-jp.wikidot.com/r-a-552")!
                ),
                Article(
                    id: "JOICLE_42_a32",
                    title: "わ-V-1260 &quot;ドネーションブラッドタブレット&quot;販売カタログ",
                    url: URL(string: "https://scp-jp.wikidot.com/w-v-1260")!
                ),
                Article(
                    id: "JOICLE_42_a33",
                    title: "報告書 #1272 「フェニックス」",
                    url: URL(string: "https://scp-jp.wikidot.com/project-joicle-1272")!
                ),
            ]
        ),
        Group(
            id: "JAGPATO_jagpato-hub_43",
            hubTitle: "日本超常組織平和友好条約機構",
            hubURL: URL(string: "https://scp-jp.wikidot.com/jagpato-hub")!,
            articles: [
                Article(
                    id: "JAGPATO_jagpato-hub_43_a0",
                    title: "特異例 028号",
                    url: URL(string: "https://scp-jp.wikidot.com/jagpato-anomalous028")!
                ),
            ]
        ),
        Group(
            id: "meiteigai_44",
            hubTitle: "酩酊街",
            hubURL: URL(string: "https://scp-jp.wikidot.com/goi-formats-jp#meiteigai")!,
            articles: [
                Article(
                    id: "meiteigai_44_a0",
                    title: "92通目",
                    url: URL(string: "https://scp-jp.wikidot.com/meiteishokan-no-92")!
                ),
                Article(
                    id: "meiteigai_44_a1",
                    title: "██通目",
                    url: URL(string: "https://scp-jp.wikidot.com/meiteishokan-no-xx")!
                ),
                Article(
                    id: "meiteigai_44_a2",
                    title: "酩酊街返送 受取人不明",
                    url: URL(string: "http://scp-jp.wikidot.com/meiteishokan-hensou-garandou")!
                ),
            ]
        ),
        Group(
            id: "mujingetsudoshu_http:__scp-jp.wikidot.com_mujin-getsudo-hub_45",
            hubTitle: "無尽月導衆",
            hubURL: URL(string: "http://scp-jp.wikidot.com/mujin-getsudo-hub")!,
            articles: [
                Article(
                    id: "mujingetsudoshu_http:__scp-jp.wikidot.com_mujin-getsudo-hub_45_a0",
                    title: "忍具第四〇一番【偽札束】",
                    url: URL(string: "https://scp-jp.wikidot.com/ningu-tyo-401")!
                ),
            ]
        ),
        Group(
            id: "yamizushi_yamizushi-hub_46",
            hubTitle: "闇寿司",
            hubURL: URL(string: "https://scp-jp.wikidot.com/yamizushi-hub")!,
            articles: [
                Article(
                    id: "yamizushi_yamizushi-hub_46_a0",
                    title: "闇寿司ファイルNo.003 &quot;鯛ブレーカー&quot;",
                    url: URL(string: "https://scp-jp.wikidot.com/yamizushi-file-no003")!
                ),
                Article(
                    id: "yamizushi_yamizushi-hub_46_a1",
                    title: "闇寿司ファイルNo.004 &quot;人工イクラ軍艦&quot;",
                    url: URL(string: "https://scp-jp.wikidot.com/yamizushi-file-no004")!
                ),
                Article(
                    id: "yamizushi_yamizushi-hub_46_a2",
                    title: "闇寿司ファイルNo.014 &quot;ありがとう水&quot;",
                    url: URL(string: "https://scp-jp.wikidot.com/yamizushi-file-no014")!
                ),
                Article(
                    id: "yamizushi_yamizushi-hub_46_a3",
                    title: "闇寿司ファイルNo.016 &quot;裏金の握らせ&quot;",
                    url: URL(string: "https://scp-jp.wikidot.com/yamizushi-file-no016")!
                ),
                Article(
                    id: "yamizushi_yamizushi-hub_46_a4",
                    title: "闇寿司ファイルNo.041 &quot;手裏剣&quot;",
                    url: URL(string: "https://scp-jp.wikidot.com/yamizushi-file-no041")!
                ),
                Article(
                    id: "yamizushi_yamizushi-hub_46_a5",
                    title: "闇寿司ファイルNo.042 &quot;カリフォルニアロール&quot;",
                    url: URL(string: "https://scp-jp.wikidot.com/yamizushi-file-no042")!
                ),
                Article(
                    id: "yamizushi_yamizushi-hub_46_a6",
                    title: "闇寿司ファイルNo.052 &quot;レールガン&quot;",
                    url: URL(string: "https://scp-jp.wikidot.com/yamizushi-file-no052")!
                ),
                Article(
                    id: "yamizushi_yamizushi-hub_46_a7",
                    title: "闇寿司ファイルNo.058 &quot;粗悪な寿司&quot;",
                    url: URL(string: "https://scp-jp.wikidot.com/yamizushi-file-no058")!
                ),
                Article(
                    id: "yamizushi_yamizushi-hub_46_a8",
                    title: "闇寿司ファイルNo.064 &quot;失伝した寿司&quot;",
                    url: URL(string: "https://scp-jp.wikidot.com/yamizushi-file-no064")!
                ),
                Article(
                    id: "yamizushi_yamizushi-hub_46_a9",
                    title: "闇寿司ファイルNo.073 &quot;原初のスシ&quot;",
                    url: URL(string: "https://scp-jp.wikidot.com/yamizushi-file-no073")!
                ),
                Article(
                    id: "yamizushi_yamizushi-hub_46_a10",
                    title: "闇寿司ファイルNo.086 &quot;生ハムスシ&quot;",
                    url: URL(string: "https://scp-jp.wikidot.com/yamizushi-file-no086")!
                ),
                Article(
                    id: "yamizushi_yamizushi-hub_46_a11",
                    title: "闇寿司ファイルNo.110 &quot;銃&quot;",
                    url: URL(string: "https://scp-jp.wikidot.com/yamizushi-file-no110")!
                ),
                Article(
                    id: "yamizushi_yamizushi-hub_46_a12",
                    title: "闇寿司ファイルNo.111 &quot;融合の握り&quot;",
                    url: URL(string: "https://scp-jp.wikidot.com/yamizushi-file-no111")!
                ),
                Article(
                    id: "yamizushi_yamizushi-hub_46_a13",
                    title: "闇寿司ファイルNo.118 &quot;ドッペルゲンガー&quot;",
                    url: URL(string: "https://scp-jp.wikidot.com/yamizushi-file-no118")!
                ),
                Article(
                    id: "yamizushi_yamizushi-hub_46_a14",
                    title: "闇寿司ファイルNo.157 &quot;シビカララーメン&quot;",
                    url: URL(string: "https://scp-jp.wikidot.com/yamizushi-file-no157")!
                ),
                Article(
                    id: "yamizushi_yamizushi-hub_46_a15",
                    title: "闇寿司ファイルNo.203&quot;かけそば&quot;",
                    url: URL(string: "https://scp-jp.wikidot.com/yamizushi-file-no203")!
                ),
                Article(
                    id: "yamizushi_yamizushi-hub_46_a16",
                    title: "闇寿司ファイルNo.204 &quot;煮干しの握り&quot;",
                    url: URL(string: "https://scp-jp.wikidot.com/yamizushi-file-no204")!
                ),
                Article(
                    id: "yamizushi_yamizushi-hub_46_a17",
                    title: "闇寿司ファイルNo.0214 &quot;チョコレートの巻き上げ&quot;",
                    url: URL(string: "https://scp-jp.wikidot.com/yamizushi-file-no0214")!
                ),
                Article(
                    id: "yamizushi_yamizushi-hub_46_a18",
                    title: "闇寿司ファイルNo.217（暫定） &quot;アバドンの握り&quot;",
                    url: URL(string: "https://scp-jp.wikidot.com/yamizushi-file-no217-provisional")!
                ),
                Article(
                    id: "yamizushi_yamizushi-hub_46_a19",
                    title: "闇寿司ファイルNo.222 &quot;猫飼いの匂わせ&quot;",
                    url: URL(string: "https://scp-jp.wikidot.com/yamizushi-file-no222")!
                ),
                Article(
                    id: "yamizushi_yamizushi-hub_46_a20",
                    title: "暗寿司ファイルNo.233 &quot;简体字卷き&quot;",
                    url: URL(string: "https://scp-jp.wikidot.com/yamizushi-file-no233")!
                ),
                Article(
                    id: "yamizushi_yamizushi-hub_46_a21",
                    title: "闇寿司ファイルNo.292 &quot;竹とんぼ&quot;",
                    url: URL(string: "https://scp-jp.wikidot.com/yamizushi-file-no292")!
                ),
                Article(
                    id: "yamizushi_yamizushi-hub_46_a22",
                    title: "闇寿司ファイルNo.303 &quot;ジーコ&quot;",
                    url: URL(string: "https://scp-jp.wikidot.com/yamizushi-file-no303")!
                ),
                Article(
                    id: "yamizushi_yamizushi-hub_46_a23",
                    title: "闇寿司ファイルNo.333 &quot;ステータスの握り&quot;",
                    url: URL(string: "https://scp-jp.wikidot.com/yamizushi-file-no333")!
                ),
                Article(
                    id: "yamizushi_yamizushi-hub_46_a24",
                    title: "闇寿司ファイルNo.403 &quot;弱みの握り&quot;",
                    url: URL(string: "https://scp-jp.wikidot.com/yamizushi-file-no403")!
                ),
                Article(
                    id: "yamizushi_yamizushi-hub_46_a25",
                    title: "闇寿司ファイルNo.431 &quot;ポシュルムナプタ&quot;",
                    url: URL(string: "https://scp-jp.wikidot.com/yamizushi-file-no431")!
                ),
                Article(
                    id: "yamizushi_yamizushi-hub_46_a26",
                    title: "闇寿司ファイルNo.480 &quot;茶碗&quot;",
                    url: URL(string: "https://scp-jp.wikidot.com/yamizushi-file-no480")!
                ),
                Article(
                    id: "yamizushi_yamizushi-hub_46_a27",
                    title: "闇寿司ファイルNo.499 &quot;イカスミスパゲッティ&quot;",
                    url: URL(string: "https://scp-jp.wikidot.com/yamizushi-file-no499")!
                ),
                Article(
                    id: "yamizushi_yamizushi-hub_46_a28",
                    title: "闇寿司ファイルNo.501　&quot;本物たるアボカド&quot;",
                    url: URL(string: "https://scp-jp.wikidot.com/yamizushi-file-no501")!
                ),
                Article(
                    id: "yamizushi_yamizushi-hub_46_a29",
                    title: "闇寿司ファイルNo.625 &quot;俺&quot;",
                    url: URL(string: "https://scp-jp.wikidot.com/yamizushi-file-no625")!
                ),
                Article(
                    id: "yamizushi_yamizushi-hub_46_a30",
                    title: "闇寿司ファイルNo.0721&quot;ちんこの握り&quot;",
                    url: URL(string: "https://scp-jp.wikidot.com/yamizushi-file-no0721")!
                ),
                Article(
                    id: "yamizushi_yamizushi-hub_46_a31",
                    title: "闇寿司ファイルNo.820 &quot;魚形埴輪&quot;",
                    url: URL(string: "https://scp-jp.wikidot.com/yamizushi-file-no820")!
                ),
                Article(
                    id: "yamizushi_yamizushi-hub_46_a32",
                    title: "闇寿司ファイルNo.823 &quot;月見団子&quot;",
                    url: URL(string: "https://scp-jp.wikidot.com/yamizushi-file-no823")!
                ),
                Article(
                    id: "yamizushi_yamizushi-hub_46_a33",
                    title: "闇寿司ファイルNo.824 &quot;恵方巻き&quot;",
                    url: URL(string: "https://scp-jp.wikidot.com/yamizushi-file-no824")!
                ),
                Article(
                    id: "yamizushi_yamizushi-hub_46_a34",
                    title: "闇寿司ファイルNo.864 &quot;ユムシ軍艦&quot;",
                    url: URL(string: "https://scp-jp.wikidot.com/yamizushi-file-no864")!
                ),
                Article(
                    id: "yamizushi_yamizushi-hub_46_a35",
                    title: "闇寿司ファイルNo.872 &quot;オゴポゴ&quot;",
                    url: URL(string: "https://scp-jp.wikidot.com/yamizushi-file-no872")!
                ),
                Article(
                    id: "yamizushi_yamizushi-hub_46_a36",
                    title: "闇寿司ファイルNo.876 &quot;サーモンライド&quot;",
                    url: URL(string: "https://scp-jp.wikidot.com/yamizushi-file-no876")!
                ),
                Article(
                    id: "yamizushi_yamizushi-hub_46_a37",
                    title: "闇寿司ファイルNo.900 &quot;ハッカクキリンの握り&quot;",
                    url: URL(string: "https://scp-jp.wikidot.com/yamizushi-file-no900")!
                ),
                Article(
                    id: "yamizushi_yamizushi-hub_46_a38",
                    title: "闇寿司ファイルNo.911 &quot;広末孝行のたたき&quot;",
                    url: URL(string: "https://scp-jp.wikidot.com/yamizushi-file-no911")!
                ),
                Article(
                    id: "yamizushi_yamizushi-hub_46_a39",
                    title: "闇寿司ファイルNo.968 &quot;キーライムパイ&quot;",
                    url: URL(string: "https://scp-jp.wikidot.com/yamizushi-file-no968")!
                ),
                Article(
                    id: "yamizushi_yamizushi-hub_46_a40",
                    title: "闇寿司ファイルNo.986 &quot;宅配ピザ&quot;",
                    url: URL(string: "https://scp-jp.wikidot.com/yamizushi-file-no986")!
                ),
                Article(
                    id: "yamizushi_yamizushi-hub_46_a41",
                    title: "闇寿司ファイルNo.1000 &quot;回らない寿司&quot;",
                    url: URL(string: "https://scp-jp.wikidot.com/yamizushi-file-no1000")!
                ),
                Article(
                    id: "yamizushi_yamizushi-hub_46_a42",
                    title: "闇寿司ファイルNo.1001 &quot;かっぱ巻き&quot;",
                    url: URL(string: "https://scp-jp.wikidot.com/yamizushi-file-no1001")!
                ),
                Article(
                    id: "yamizushi_yamizushi-hub_46_a43",
                    title: "闇寿司ファイルNo.1007 &quot;アブリンガーZ&quot;",
                    url: URL(string: "https://scp-jp.wikidot.com/yamizushi-file-no1007")!
                ),
                Article(
                    id: "yamizushi_yamizushi-hub_46_a44",
                    title: "闇寿司ファイルNo.1012 &quot;ザワークラウト&quot;",
                    url: URL(string: "https://scp-jp.wikidot.com/yamizushi-file-no1012")!
                ),
                Article(
                    id: "yamizushi_yamizushi-hub_46_a45",
                    title: "闇寿司ファイルNo.1031 &quot;魚の目玉軍艦&quot;",
                    url: URL(string: "https://scp-jp.wikidot.com/yamizushi-file-no1031")!
                ),
                Article(
                    id: "yamizushi_yamizushi-hub_46_a46",
                    title: "闇寿司ファイルNo.1051 &quot;横綱の廻し&quot;",
                    url: URL(string: "https://scp-jp.wikidot.com/yamizushi-file-no1051")!
                ),
                Article(
                    id: "yamizushi_yamizushi-hub_46_a47",
                    title: "闇寿司ファイルNo.1224 &quot;闇鍋&quot;",
                    url: URL(string: "https://scp-jp.wikidot.com/yamizushi-file-no1224")!
                ),
                Article(
                    id: "yamizushi_yamizushi-hub_46_a48",
                    title: "闇寿司ファイルNo.1225 &quot;寿司パン&quot;",
                    url: URL(string: "https://scp-jp.wikidot.com/yamizushi-file-no1225")!
                ),
                Article(
                    id: "yamizushi_yamizushi-hub_46_a49",
                    title: "闇寿司ファイルNo.1714 &quot;███の握り&quot;",
                    url: URL(string: "https://scp-jp.wikidot.com/yamizushi-file-no1714")!
                ),
                Article(
                    id: "yamizushi_yamizushi-hub_46_a50",
                    title: "闇寿司ファイルNo.1916 &quot;シャリオット&quot;",
                    url: URL(string: "https://scp-jp.wikidot.com/yamizushi-file-no1916")!
                ),
                Article(
                    id: "yamizushi_yamizushi-hub_46_a51",
                    title: "闇寿司ファイルNo.2000（仮） &quot;謎の機械&quot;",
                    url: URL(string: "https://scp-jp.wikidot.com/yamizushi-file-no2000kari")!
                ),
                Article(
                    id: "yamizushi_yamizushi-hub_46_a52",
                    title: "闇寿司ファイルNo.2641 &quot;ビリヤニ寿司&quot;",
                    url: URL(string: "https://scp-jp.wikidot.com/yamizushi-file-no2641")!
                ),
                Article(
                    id: "yamizushi_yamizushi-hub_46_a53",
                    title: "闇寿司ファイルNo.3110 &quot;ヒトデの握り&quot;",
                    url: URL(string: "https://scp-jp.wikidot.com/yamizushi-file-no3110")!
                ),
                Article(
                    id: "yamizushi_yamizushi-hub_46_a54",
                    title: "闇寿司ファイルNo.3355 &quot;マニコロ巻き寿司&quot;",
                    url: URL(string: "https://scp-jp.wikidot.com/yamizushi-file-no3355")!
                ),
                Article(
                    id: "yamizushi_yamizushi-hub_46_a55",
                    title: "闇寿司ファイルNo.4113 &quot;不和殺蟹の蟹味噌軍艦&quot;",
                    url: URL(string: "https://scp-jp.wikidot.com/yamizushi-file-no4113")!
                ),
                Article(
                    id: "yamizushi_yamizushi-hub_46_a56",
                    title: "闇寿司ファイルNo.███ &quot;ベールの巻きあげ&quot;",
                    url: URL(string: "https://scp-jp.wikidot.com/yamizushi-file-noxxx")!
                ),
                Article(
                    id: "yamizushi_yamizushi-hub_46_a57",
                    title: "闇寿司ファイルNo.033-D &quot;トラック&quot;",
                    url: URL(string: "https://scp-jp.wikidot.com/yamizushi-file-no033-d")!
                ),
                Article(
                    id: "yamizushi_yamizushi-hub_46_a58",
                    title: "闇寿司ファイルNo.177-D &quot;メタンフェガリン&quot;",
                    url: URL(string: "https://scp-jp.wikidot.com/yamizushi-file-no177-d")!
                ),
                Article(
                    id: "yamizushi_yamizushi-hub_46_a59",
                    title: "闇寿司ファイルNo.314-D &quot;スシ投げ&quot;",
                    url: URL(string: "https://scp-jp.wikidot.com/yamizushi-file-no314-d")!
                ),
                Article(
                    id: "yamizushi_yamizushi-hub_46_a60",
                    title: "闇寿司ファイルNo.626-D &quot;お前&quot;",
                    url: URL(string: "https://scp-jp.wikidot.com/yamizushi-file-no626-d")!
                ),
                Article(
                    id: "yamizushi_yamizushi-hub_46_a61",
                    title: "闇寿司ファイルNo.644-D &quot;アニサキスの潜らせ&quot;",
                    url: URL(string: "https://scp-jp.wikidot.com/yamizushi-file-no644-d")!
                ),
                Article(
                    id: "yamizushi_yamizushi-hub_46_a62",
                    title: "闇寿司ファイルNo.795-D &quot;地球&quot;",
                    url: URL(string: "https://scp-jp.wikidot.com/yamizushi-file-no795-d")!
                ),
                Article(
                    id: "yamizushi_yamizushi-hub_46_a63",
                    title: "闇寿司ファイルNo.1010-D &quot;釣り竿(リール付き)&quot;",
                    url: URL(string: "https://scp-jp.wikidot.com/yamizushi-file-no1010-d")!
                ),
                Article(
                    id: "yamizushi_yamizushi-hub_46_a64",
                    title: "闇寿司ファイルNo.625 Re &quot;俺&quot;",
                    url: URL(string: "https://scp-jp.wikidot.com/yamizushi-file-no625-re")!
                ),
                Article(
                    id: "yamizushi_yamizushi-hub_46_a65",
                    title: "闇寿司ファイルNo.0721 Re-D &quot;ちんこの握り&quot;",
                    url: URL(string: "https://scp-jp.wikidot.com/yamizushi-file-no0721-re-d")!
                ),
                Article(
                    id: "yamizushi_yamizushi-hub_46_a66",
                    title: "闇寿司ケースファイル &quot;仁平事件&quot;",
                    url: URL(string: "https://scp-jp.wikidot.com/yamizushi-case-file-nihira")!
                ),
                Article(
                    id: "yamizushi_yamizushi-hub_46_a67",
                    title: "闇寿司ケースファイル &quot;SaBA襲撃事件&quot;",
                    url: URL(string: "https://scp-jp.wikidot.com/yamizushi-case-file-saba-assault")!
                ),
                Article(
                    id: "yamizushi_yamizushi-hub_46_a68",
                    title: "入店お断りリストNo.008 &quot;マドンナリリー&quot;",
                    url: URL(string: "https://scp-jp.wikidot.com/yamizushi-blacklist-008")!
                ),
                Article(
                    id: "yamizushi_yamizushi-hub_46_a69",
                    title: "闇寿司開発記No.203 &quot;恵方回し&quot;",
                    url: URL(string: "https://scp-jp.wikidot.com/yamizushi-madscience-203")!
                ),
                Article(
                    id: "yamizushi_yamizushi-hub_46_a70",
                    title: "闇寿司開発記No.483 &quot;夜間の襲撃に対抗する握り&quot;",
                    url: URL(string: "https://scp-jp.wikidot.com/yamizushi-madscience-483")!
                ),
                Article(
                    id: "yamizushi_yamizushi-hub_46_a71",
                    title: "闇寿司開発記No.878 &quot;制空権の握り&quot;",
                    url: URL(string: "https://scp-jp.wikidot.com/yamizushi-madscience-878")!
                ),
            ]
        ),
        Group(
            id: "yumemi_47",
            hubTitle: "夢見テクノロジー",
            hubURL: URL(string: "https://scp-jp.wikidot.com/goi-formats-jp#yumemi")!,
            articles: [
                Article(
                    id: "yumemi_47_a0",
                    title: "プロジェクトナンバー:0189 &quot;シロップ漬けの果実&quot;",
                    url: URL(string: "https://scp-jp.wikidot.com/project-no-0189")!
                ),
                Article(
                    id: "yumemi_47_a1",
                    title: "プロジェクトナンバー:0681 &quot;[N/A]KQJ10&quot;",
                    url: URL(string: "https://scp-jp.wikidot.com/project-no-0681")!
                ),
            ]
        ),
        Group(
            id: "other-goi-jp_48",
            hubTitle: "その他/小規模な要注意団体",
            hubURL: URL(string: "https://scp-jp.wikidot.com/goi-formats-jp#other-goi-jp")!,
            articles: [
                Article(
                    id: "other-goi-jp_48_a0",
                    title: "講義#0003 - マクロカオシズムってなーに？",
                    url: URL(string: "https://scp-jp.wikidot.com/kankan-s-goiformat-paradogs-1")!
                ),
                Article(
                    id: "other-goi-jp_48_a1",
                    title: "講義#0003 - マグロカツオシズムってなーに？",
                    url: URL(string: "https://scp-jp.wikidot.com/goiformat-paradogs-1-j")!
                ),
                Article(
                    id: "other-goi-jp_48_a2",
                    title: "Sho-Hei project 公式webサイト",
                    url: URL(string: "https://scp-jp.wikidot.com/shouhei-project-001")!
                ),
                Article(
                    id: "other-goi-jp_48_a3",
                    title: "「鮨と米について」スシアカデミア学術紀要，Vol 103 2020 pp.160-167",
                    url: URL(string: "https://scp-jp.wikidot.com/sushi-acad-vol103-pp160-167")!
                ),
                Article(
                    id: "other-goi-jp_48_a4",
                    title: "カルテNo.6927 ハムスター、ケガ",
                    url: URL(string: "https://scp-jp.wikidot.com/kusuno-karte-no-6927")!
                ),
                Article(
                    id: "other-goi-jp_48_a5",
                    title: "「社会」の記事 2030年11月26日 - 帝都経済新聞",
                    url: URL(string: "https://scp-jp.wikidot.com/teito-keizai-2030-11-26")!
                ),
                Article(
                    id: "other-goi-jp_48_a6",
                    title: "「国際」の記事 2045年2月10日 - 帝都経済新聞",
                    url: URL(string: "https://scp-jp.wikidot.com/teito-keizai-2045-02-10")!
                ),
                Article(
                    id: "other-goi-jp_48_a7",
                    title: "M-81-0020",
                    url: URL(string: "https://scp-jp.wikidot.com/m-81-0020")!
                ),
                Article(
                    id: "other-goi-jp_48_a8",
                    title: "奇想天獄 1974年第8号 「非人間的演劇表現」",
                    url: URL(string: "https://scp-jp.wikidot.com/kisoutengoku-1974-vol08")!
                ),
                Article(
                    id: "other-goi-jp_48_a9",
                    title: "奇想天獄 2025年第3号 「時間旅行と服」",
                    url: URL(string: "https://scp-jp.wikidot.com/kisoutengoku-2025-vol03")!
                ),
                Article(
                    id: "other-goi-jp_48_a10",
                    title: "奇想天獄 2025年第7号 「潜行、余剰次元都市」",
                    url: URL(string: "https://scp-jp.wikidot.com/kisoutengoku-2025-vol07")!
                ),
                Article(
                    id: "other-goi-jp_48_a11",
                    title: "奇想天獄 2026年第2号 「超常芸人と笑いの新世代」",
                    url: URL(string: "https://scp-jp.wikidot.com/kisoutengoku-2026-vol02")!
                ),
                Article(
                    id: "other-goi-jp_48_a12",
                    title: "ユグドラシル･ピーク &quot;フレイスヴニル&quot;",
                    url: URL(string: "https://scp-jp.wikidot.com/yggdrasill-peak-freisvenil")!
                ),
                Article(
                    id: "other-goi-jp_48_a13",
                    title: "ユグドラシル･ピーク &quot;レーヴァテイン&quot;",
                    url: URL(string: "https://scp-jp.wikidot.com/yggdrasill-peak-laevateinn")!
                ),
                Article(
                    id: "other-goi-jp_48_a14",
                    title: "ユグドラシル・ピーク &quot;イルミンスール&quot;",
                    url: URL(string: "https://scp-jp.wikidot.com/yggdrasill-peak-irminsul")!
                ),
                Article(
                    id: "other-goi-jp_48_a15",
                    title: "異災分霊を活用した神格存在の改霊・矯正の実証実験",
                    url: URL(string: "https://scp-jp.wikidot.com/rigaiken-repo-research-proposal-2028-03-13-in-98")!
                ),
                Article(
                    id: "other-goi-jp_48_a16",
                    title: "ヒユーイソン効果に関する異常事例報告群",
                    url: URL(string: "https://scp-jp.wikidot.com/camr-about-the-hewison-effect")!
                ),
                Article(
                    id: "other-goi-jp_48_a17",
                    title: "MEI Case.0314 -ボウラナーラ・メタモルフォーシス-",
                    url: URL(string: "https://scp-jp.wikidot.com/mei-case-0314")!
                ),
                Article(
                    id: "other-goi-jp_48_a18",
                    title: "PE013: 自己安定性不信型悪夢障害",
                    url: URL(string: "https://scp-jp.wikidot.com/dmam-pe013")!
                ),
                Article(
                    id: "other-goi-jp_48_a19",
                    title: "幻影 第三三二號:《骸工》",
                    url: URL(string: "https://scp-jp.wikidot.com/genei-332")!
                ),
                Article(
                    id: "other-goi-jp_48_a20",
                    title: "今日の気分はとっても墓荒らしな俺 (『呪いのビジョン 特別版vol4』収録; 1996年)",
                    url: URL(string: "https://scp-jp.wikidot.com/lostmedia-graverobber")!
                ),
                Article(
                    id: "other-goi-jp_48_a21",
                    title: "殻々商品ページ【永久ひんやりクーラーボックス】",
                    url: URL(string: "https://scp-jp.wikidot.com/garagara-shoppingpage-coolerbox")!
                ),
            ]
        ),
        Group(
            id: "other-branch_49",
            hubTitle: "聖クリスティーナ学院",
            hubURL: URL(string: "https://scp-jp.wikidot.com/goi-formats-jp#other-branch")!,
            articles: [
                Article(
                    id: "other-branch_49_a0",
                    title: "生徒ファイル—S11443617",
                    url: URL(string: "https://scp-jp.wikidot.com/reg-profile-s11443617")!
                ),
            ]
        ),
        Group(
            id: "other-branch_yixuehuihub_50",
            hubTitle: "中華異学会",
            hubURL: URL(string: "https://scp-jp.wikidot.com/yixuehuihub")!,
            articles: [
                Article(
                    id: "other-branch_yixuehuihub_50_a0",
                    title: "異学捌零弐 八岐大蛇",
                    url: URL(string: "https://scp-jp.wikidot.com/yixue802")!
                ),
            ]
        ),
        Group(
            id: "other-branch_fixedflowers_51",
            hubTitle: "修正花卉",
            hubURL: URL(string: "https://scp-jp.wikidot.com/fixedflowers")!,
            articles: [
                Article(
                    id: "other-branch_fixedflowers_51_a0",
                    title: "歯車筐に篠突く緑雨",
                    url: URL(string: "https://scp-jp.wikidot.com/early-summer-rain-on-arca")!
                ),
            ]
        ),
        Group(
            id: "other-branch_gsf_52",
            hubTitle: "グリーン・スパロウ財団",
            hubURL: URL(string: "https://scp-jp.wikidot.com/gsf")!,
            articles: [
                Article(
                    id: "other-branch_gsf_52_a0",
                    title: "BIRDS-023：幸せの青い鳥",
                    url: URL(string: "https://scp-jp.wikidot.com/birds-023")!
                ),
                Article(
                    id: "other-branch_gsf_52_a1",
                    title: "BIRDS-024：淑女症",
                    url: URL(string: "https://scp-jp.wikidot.com/birds-024")!
                ),
                Article(
                    id: "other-branch_gsf_52_a2",
                    title: "BIRDS-025：連環食虫",
                    url: URL(string: "https://scp-jp.wikidot.com/birds-025")!
                ),
                Article(
                    id: "other-branch_gsf_52_a3",
                    title: "BIRDS-026：共命之鳥",
                    url: URL(string: "https://scp-jp.wikidot.com/birds-026")!
                ),
                Article(
                    id: "other-branch_gsf_52_a4",
                    title: "BIRDS-027：夜に鳴く不吉な鳥",
                    url: URL(string: "https://scp-jp.wikidot.com/birds-027")!
                ),
                Article(
                    id: "other-branch_gsf_52_a5",
                    title: "BIRDS-816：ウェスターマーク拡張パッチ",
                    url: URL(string: "https://scp-jp.wikidot.com/birds-816")!
                ),
                Article(
                    id: "other-branch_gsf_52_a6",
                    title: "BIRDS-XXX：伴侶代わりの［生物名］",
                    url: URL(string: "https://scp-jp.wikidot.com/birds-xxx")!
                ),
            ]
        ),
        Group(
            id: "tingforum-com_53",
            hubTitle: "TINGフォーラム",
            hubURL: URL(string: "https://scp-jp.wikidot.com/tingforum-com")!,
            articles: [
                Article(
                    id: "tingforum-com_53_a0",
                    title: "好きやねん、アウターオーサカGP",
                    url: URL(string: "https://scp-jp.wikidot.com/oo-track")!
                ),
            ]
        ),
        Group(
            id: "revue_54",
            hubTitle: "劇組",
            hubURL: URL(string: "https://scp-jp.wikidot.com/revue")!,
            articles: [
                Article(
                    id: "revue_54_a0",
                    title: "演目-とこしえの憩い",
                    url: URL(string: "https://scp-jp.wikidot.com/revue-damnatio-memoriae")!
                ),
                Article(
                    id: "revue_54_a1",
                    title: "演目- 一瞬の檻に閉じ込めて",
                    url: URL(string: "https://scp-jp.wikidot.com/revue-du-bist-so-schoen")!
                ),
            ]
        ),
        Group(
            id: "55",
            hubTitle: "ニルヴァーナ",
            hubURL: URL(string: "https://scp-jp.wikidot.com/goi-formats-jp#toc59")!,
            articles: [
                Article(
                    id: "55_a0",
                    title: "「POLLYANNA」推進提言、2018年 12月 24日",
                    url: URL(string: "https://scp-jp.wikidot.com/zephyr-2991")!
                ),
            ]
        ),
        Group(
            id: "saphir-centre_56",
            hubTitle: "SAPHIR",
            hubURL: URL(string: "https://scp-jp.wikidot.com/saphir-centre")!,
            articles: [
                Article(
                    id: "saphir-centre_56_a0",
                    title: "調査報告書: 聖ショパンの再臨",
                    url: URL(string: "https://scp-jp.wikidot.com/zetetic-bulletin-the-revival-of-st-chopin")!
                ),
            ]
        ),
        Group(
            id: "57",
            hubTitle: "ユニヴェルジル王国",
            hubURL: URL(string: "https://scp-jp.wikidot.com/goi-formats-jp#toc62")!,
            articles: [
                Article(
                    id: "57_a0",
                    title: "無の灯台",
                    url: URL(string: "https://scp-jp.wikidot.com/le-phare-du-vide")!
                ),
            ]
        ),
        Group(
            id: "informe-sobre-la-sociedad-antares_58",
            hubTitle: "人類精神再生の為のアンタレス協会",
            hubURL: URL(string: "https://scp-jp.wikidot.com/informe-sobre-la-sociedad-antares")!,
            articles: [
                Article(
                    id: "informe-sobre-la-sociedad-antares_58_a0",
                    title: "職人シャウラの証言, 2001/9/11",
                    url: URL(string: "https://scp-jp.wikidot.com/testimony-by-fellowcraft-shaula")!
                ),
            ]
        ),
        Group(
            id: "machina-portal_59",
            hubTitle: "Machina",
            hubURL: URL(string: "https://scp-jp.wikidot.com/machina-portal")!,
            articles: [
                Article(
                    id: "machina-portal_59_a0",
                    title: "ASP-210-JP",
                    url: URL(string: "https://scp-jp.wikidot.com/asp-210-jp")!
                ),
                Article(
                    id: "machina-portal_59_a1",
                    title: "ASP-650-JP",
                    url: URL(string: "https://scp-jp.wikidot.com/asp-650-jp")!
                ),
            ]
        ),
        Group(
            id: "http:__scp-jp.wikidot.com_chonghaejin_60",
            hubTitle: "清海鎮",
            hubURL: URL(string: "http://scp-jp.wikidot.com/chonghaejin")!,
            articles: [
                Article(
                    id: "http:__scp-jp.wikidot.com_chonghaejin_60_a0",
                    title: "空望遠暗",
                    url: URL(string: "http://scp-jp.wikidot.com/karami-kuusyo")!
                ),
            ]
        ),
        Group(
            id: "laundry-of-miya_61",
            hubTitle: "洗濯部門",
            hubURL: URL(string: "https://scp-jp.wikidot.com/laundry-of-miya")!,
            articles: [
                Article(
                    id: "laundry-of-miya_61_a0",
                    title: "洗濯タグ: 藍-2013 ※通称&quot;桑名博士&quot;",
                    url: URL(string: "https://scp-jp.wikidot.com/blue-2013")!
                ),
                Article(
                    id: "laundry-of-miya_61_a1",
                    title: "洗濯タグ: 紅-8010",
                    url: URL(string: "https://scp-jp.wikidot.com/red-8010")!
                ),
            ]
        ),
    ]
}
