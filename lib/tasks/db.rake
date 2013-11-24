# encoding: utf-8

namespace :db do
  namespace :clear do
    desc 'Remove all votes.'
    task :votes => :environment do
      Vote.destroy_all
    end

    desc 'Remove all representatives'
    task :representatives => :environment do
      Representative.destroy_all
    end

    desc 'Remove all promises'
    task :promises => :environment do
      Promise.destroy_all
    end

    desc 'Remove all issues'
    task :issues => :environment do
      Issue.destroy_all
    end
  end

  namespace :move do
    # temporary task to move data
    task :vote2proposition => :environment do
      PropositionConnection.all.each do |pc|
        prop_ids = CONN_TO_PROPS[pc.id]
        p pc.id => prop_ids

        if prop_ids.nil?
          props = pc.vote.propositions
          if props.size == 1 || !pc.issue.published?
            pc.proposition_id = props.first
            pc.save!
          else
            raise "no mapping found for #{pc.inspect}"
          end
        elsif prop_ids.size <= 0
          raise "no prop ids found for #{pc.id}"
        else
          first = prop_ids.shift

          pc.proposition_id = first
          pc.save!

          prop_ids.each do |prop_id|
            dup_pc = pc.dup
            dup_pc.proposition_id = prop_id
            dup_pc.save!
          end
        end
      end

      # no need to override vote_id if there is only one
      PropositionConnection.includes(:proposition).each do |pc|
        if pc.proposition.votes.size == 1
          pc.vote_id = nil
          pc.save!
        end
      end
    end
  end

  CONN_TO_PROPS = {
   1650=>[1725],
   1430=>[3534],
   1663=>[9394],
   997=>[3032],
   789=>[7083],
   1050=>[6066],
   796=>[4748],
   457=>[4840],
   996=>[4490],
   456=>[4747],
   741=>[6831],
   1006=>[6422],
   1761=>[2122],
   890=>[6824],
   648=>[1953],
   800=>[6340],
   1114=>[3577],
   1635=>[8648],
   1636=>[4116],
   1652=>[6066],
   1916=>[3519],
   1917=>[6799],
   1637=>[6335],
   1918=>[5849],
   1919=>[5875],
   279=>[1938],
   911=>[4948],
   333=>[1495],
   913=>[6454],
   1920=>[5841],
   1921=>[4946],
   1922=>[5571],
   1923=>[5859],
   1924=>[5879],
   1925=>[5883],
   580=>[2122],
   834=>[6894],
   372=>[1344],
   1083=>[1667],
   1653=>[6062],
   769=>[6422],
   419=>[3051],
   801=>[5932],
   389=>[409],
   814=>[5931],
   553=>[3987],
   555=>[2620],
   806=>[5283],
   805=>[200],
   807=>[6983],
   1651=>[3589],
   849=>[1476],
   850=>[4005],
   804=>[3729],
   1654=>[1673],
   815=>[5931],
   808=>[6141],
   809=>[2266],
   810=>[3702],
   811=>[1817],
   812=>[3722],
   813=>[1803],
   552=>[5328],
   318=>[1601],
   319=>[1602],
   649=>[3920],
   1165=>[6058],
   284=>[9979],
   1647=>[1667],
   934=>[200],
   922=>[2593],
   923=>[2274],
   924=>[2277],
   921=>[2576],
   802=>[2273],
   918=>[6465],
   1184=>[2130],
   1116=>[2118],
   448=>[5028],
   586=>[2131],
   1655=>[8415],
   332=>[1449],
   1431=>[3533],
   329=>[1383],
   914=>[6465],
   420=>[459],
   758=>[6831],
   674=>[5580],
   339=>[1643],
   633=>[4980],
   634=>[4981],
   1656=>[8599],
   587=>[2128],
   1657=>[9355],
   773=>[6278],
   251=>[385],
   1089=>[3130],
   765=>[6776],
   766=>[4113],
   767=>[4485],
   353=>[944],
   1272=>[4028],
   1533=>[7140],
   768=>[6113],
   1658=>[23],
   1659=>[5511],
   1660=>[9351],
   825=>[6058],
   716=>[4649],
   717=>[4650],
   643=>[5220],
   791=>[6780],
   727=>[3983],
   588=>[1673],
   1185=>[3581],
   1187=>[2128],
   1314=>[2118],
   917=>[1044],
   1093=>[2177],
   1661=>[9347],
   730=>[5471],
   1118=>[2718],
   726=>[1385],
   1052=>[1667],
   1212=>[4887],
   826=>[7083],
   59=>[143],
   1232=>[2203],
   1053=>[3577],
   391=>[646],
   1054=>[6143],
   602=>[4052],
   831=>[3683],
   1662=>[9349],
   832=>[1876],
   833=>[674],
   1428=>[379],
   1120=>[3645, 3647],
   1186=>[1673],
   1119=>[4087],
   1197=>[6058],
   966=>[3133],
   1541=>[5206],
   1667=>[5252],
   969=>[3060],
   538=>[2118, 2120],
   925=>[1817],
   1056=>[6058],
   1057=>[6055],
   1298=>[3655],
   1277=>[5327],
   835=>[7731],
   1435=>[3581],
   926=>[1803],
   927=>[2248],
   929=>[2190],
   935=>[5283],
   1092=>[1077],
   1205=>[6066],
   1666=>[525],
   374=>[1988],
   1004=>[1526],
   930=>[3733],
   931=>[6163],
   1003=>[6282],
   848=>[2680],
   1672=>[520],
   1486=>[5471],
   836=>[1479],
   928=>[1750],
   932=>[214],
   933=>[391],
   1830=>[1674],
   1670=>[2198],
   734=>[5943],
   690=>[979],
   594=>[2347],
   703=>[3588],
   252=>[1343],
   704=>[1674],
   851=>[1920],
   1207=>[1675],
   486=>[22],
   666=>[1532],
   1086=>[6055],
   884=>[3577],
   615=>[5541],
   782=>[3977],
   1117=>[6321],
   1669=>[8244],
   702=>[2118],
   606=>[2243],
   1519=>[8676],
   514=>[4964],
   1671=>[519],
   829=>[1946],
   1673=>[522],
   1674=>[524],
   1675=>[521],
   1676=>[523],
   1244=>[1],
   1247=>[2122],
   1248=>[1671],
   1665=>[1724],
   1281=>[4572],
   852=>[6938],
   854=>[4099],
   54=>[1194],
   1245=>[556],
   799=>[6747],
   418=>[1949],
   1593=>[2130],
   1196=>[6375],
   300=>[615],
   610=>[1710],
   564=>[3469],
   1370=>[453],
   863=>[1386],
   803=>[1816],
   653=>[5293],
   654=>[2258],
   795=>[6986],
   794=>[6151],
   551=>[4112],
   816=>[5936],
   1112=>[6339],
   1036=>[2130],
   940=>[3577],
   250=>[384],
   869=>[6709],
   591=>[2130],
   1287=>[5326],
   669=>[1674],
   310=>[942],
   464=>[1294],
   672=>[5261],
   772=>[6790],
   770=>[6683],
   1037=>[2128],
   1039=>[2131],
   1051=>[2118],
   942=>[1667],
   889=>[6825],
   939=>[2118],
   1285=>[449],
   471=>[452],
   554=>[5538],
   1826=>[2128],
   1765=>[2476],
   941=>[3581],
   938=>[2128],
   943=>[6055],
   877=>[2128],
   883=>[3581],
   876=>[7750],
   710=>[484],
   1252=>[6073],
   1574=>[668],
   1680=>[3588],
   875=>[2118],
   31=>[272],
   723=>[5272],
   1229=>[6265, 6266],
   1246=>[6062],
   817=>[6139],
   1684=>[1673],
   301=>[620],
   894=>[6586],
   1846=>[6073],
   896=>[7549],
   1683=>[3581],
   707=>[1781],
   1682=>[2130],
   1253=>[3588],
   944=>[2335],
   22=>[1441],
   1572=>[9285],
   893=>[6827],
   1678=>[152],
   1685=>[2128],
   705=>[2130],
   864=>[1438],
   865=>[2620],
   313=>[1970],
   671=>[2130],
   49=>[279],
   1679=>[151],
   764=>[6873],
   759=>[6829],
   880=>[1667],
   899=>[6412],
   1520=>[8654],
   945=>[2041],
   393=>[1626, 1627],
   32=>[273],
   1695=>[3179],
   394=>[1628],
   1687=>[9259],
   1688=>[4719],
   1517=>[8437],
   1011=>[7121],
   981=>[2128],
   1689=>[6322],
   1690=>[6316],
   1576=>[9132],
   1691=>[6307],
   1692=>[6321],
   1693=>[3949],
   1041=>[1667],
   971=>[943],
   1694=>[6288],
   1696=>[4260],
   1697=>[1297],
   908=>[4131],
   1042=>[1675],
   1698=>[3179],
   1699=>[8190],
   1700=>[23],
   1701=>[33],
   1702=>[5471],
   886=>[5982],
   888=>[5980],
   892=>[5981],
   550=>[4802, 4803],
   266=>[1103],
   775=>[5439],
   322=>[723],
   975=>[7106],
   1764=>[5539],
   565=>[3470, 3471],
   774=>[3627],
   531=>[4331],
   509=>[3464],
   459=>[4749],
   460=>[4841],
   1703=>[6875],
   455=>[2608],
   614=>[5716],
   454=>[2609],
   1704=>[2131],
   1584=>[9212],
   1705=>[1675],
   897=>[6585],
   510=>[3466],
   976=>[5500],
   985=>[4684],
   948=>[6880],
   977=>[5565, 5549],
   216=>[1870],
   258=>[624],
   747=>[7107],
   1121=>[6749],
   749=>[1787],
   340=>[1644],
   987=>[4701],
   315=>[1958],
   748=>[3698],
   900=>[5138],
   525=>[5283],
   314=>[1971],
   581=>[2134],
   1122=>[2130],
   253=>[237],
   254=>[238],
   255=>[248],
   257=>[251],
   1123=>[2128],
   373=>[1990],
   1706=>[2131],
   330=>[1386],
   30=>[271],
   270=>[281],
   556=>[4094, 4095],
   1707=>[1675],
   583=>[2128],
   1242=>[4131],
   676=>[2064],
   1708=>[3589],
   1709=>[6066],
   696=>[3577],
   675=>[2063],
   695=>[1043],
   609=>[1675],
   1710=>[695],
   1124=>[2118],
   278=>[325],
   326=>[1603],
   584=>[1673],
   585=>[3581],
   1125=>[2131],
   218=>[1388],
   901=>[3996],
   1249=>[3577],
   1250=>[6055],
   1251=>[3610],
   1712=>[8301],
   1128=>[1667],
   1713=>[4960],
   217=>[1871],
   593=>[32],
   1717=>[2118],
   793=>[6779],
   321=>[722],
   334=>[512],
   348=>[1321],
   343=>[310],
   345=>[931],
   344=>[929],
   1038=>[2118],
   347=>[928],
   346=>[932],
   1129=>[1675],
   1711=>[4961],
   380=>[133],
   352=>[937],
   355=>[1320],
   351=>[281],
   1718=>[3877],
   356=>[553],
   357=>[554],
   1600=>[9355],
   320=>[720, 721],
   659=>[1667],
   640=>[4931],
   376=>[644],
   390=>[625],
   639=>[5298],
   867=>[4101],
   902=>[2663],
   359=>[1354],
   638=>[213],
   383=>[2042],
   382=>[727],
   1715=>[3577],
   1716=>[1667],
   363=>[583],
   642=>[2378],
   1040=>[1674],
   361=>[581],
   362=>[582],
   360=>[580],
   647=>[391],
   644=>[5207],
   411=>[3050],
   1445=>[4870],
   1447=>[1242],
   597=>[2002],
   529=>[2871],
   650=>[1555],
   1719=>[1667, 1668],
   423=>[1370],
   424=>[1372],
   1592=>[1673],
   859=>[4890],
   1260=>[6949],
   425=>[3030],
   48=>[1323],
   537=>[2072],
   1596=>[3588],
   1126=>[1674],
   1127=>[1673],
   745=>[7087],
   1081=>[386],
   603=>[3680],
   677=>[5779],
   519=>[4050],
   1720=>[3577],
   1721=>[6055],
   1723=>[2],
   1280=>[3457],
   1333=>[4052],
   431=>[2513],
   433=>[628],
   422=>[460, 461, 462],
   949=>[5933],
   1725=>[847],
   1722=>[7102],
   1334=>[1449],
   432=>[565],
   866=>[2672],
   442=>[18],
   443=>[67],
   441=>[2518],
   449=>[5030],
   605=>[1774],
   855=>[6953],
   1084=>[3577],
   1002=>[4131],
   1335=>[2684],
   663=>[3977],
   487=>[1345],
   846=>[5998],
   847=>[6062],
   670=>[3588],
   658=>[2118],
   444=>[1],
   465=>[1294],
   1686=>[6696, 6697],
   1282=>[5329],
   1279=>[5109],
   507=>[3463],
   1130=>[3588],
   1131=>[3577],
   541=>[2614],
   952=>[1588],
   453=>[4345],
   1132=>[3581],
   1025=>[3663],
   518=>[2894],
   513=>[4485],
   1726=>[6512],
   215=>[999],
   1226=>[5938],
   331=>[1421],
   868=>[6423],
   549=>[4805],
   544=>[726],
   545=>[4881],
   1727=>[4309],
   1211=>[3574],
   548=>[4804],
   566=>[3468],
   1728=>[3070],
   1729=>[2589],
   472=>[31],
   577=>[2130],
   526=>[3705],
   575=>[1674],
   1732=>[3895],
   558=>[5520],
   999=>[6066],
   664=>[2493],
   1000=>[3589],
   1730=>[2429],
   1602=>[9351],
   559=>[5511],
   1133=>[6062],
   592=>[1674],
   715=>[3947],
   1032=>[3205],
   964=>[3211],
   560=>[5471],
   728=>[2617],
   1581=>[8676],
   955=>[2638],
   1348=>[6550],
   399=>[2100, 2099],
   722=>[5589],
   1733=>[6465],
   528=>[4811],
   1583=>[9242],
   1668=>[5257],
   1134=>[6437],
   954=>[6954],
   546=>[4949],
   731=>[5336],
   516=>[4180],
   946=>[4988],
   1731=>[1588],
   956=>[2131],
   957=>[1675],
   547=>[4950],
   1079=>[312],
   752=>[2242],
   736=>[6900],
   753=>[6121],
   743=>[5518],
   958=>[3589],
   438=>[566],
   986=>[6879],
   1166=>[3581],
   1734=>[9130],
   1740=>[4762],
   1741=>[255],
   1742=>[254],
   1743=>[6645],
   1744=>[197],
   1745=>[7749],
   1677=>[2171],
   1735=>[5515],
   512=>[1625],
   751=>[5010],
   750=>[5502],
   1219=>[5505],
   733=>[5944],
   732=>[5945],
   959=>[6066],
   327=>[1604],
   950=>[3101],
   725=>[5337],
   771=>[6685],
   437=>[567],
   744=>[6135],
   1267=>[6934],
   1276=>[3490],
   729=>[5495],
   1189=>[2122],
   1273=>[6390, 6404],
   1559=>[9394],
   1773=>[5520],
   26=>[1292],
   754=>[5958],
   1261=>[6562],
   1264=>[7020],
   781=>[6283],
   530=>[2136],
   1560=>[9355],
   1192=>[1710],
   532=>[3089],
   982=>[2118],
   1153=>[2118],
   1320=>[6148],
   1603=>[9349],
   656=>[1802],
   953=>[596],
   655=>[3710],
   652=>[206],
   792=>[6776],
   861=>[4891],
   1047=>[6062],
   1048=>[6058],
   1049=>[6055],
   818=>[5973, 5974],
   1137=>[7911],
   912=>[6452],
   1139=>[7910],
   1450=>[4562],
   369=>[1973],
   1195=>[6073],
   1384=>[7714],
   1451=>[4559],
   1105=>[2264],
   1452=>[5253],
   1106=>[2130],
   590=>[1294],
   1023=>[1751],
   1067=>[1673],
   1020=>[1754],
   1021=>[3673],
   1024=>[1766],
   1029=>[5995, 5996],
   1383=>[4868],
   1336=>[4043],
   1386=>[7149],
   447=>[5412],
   19=>[1883],
   1140=>[7050],
   830=>[4290],
   1200=>[2128],
   1199=>[1673],
   1203=>[1674],
   1404=>[3996],
   1313=>[1667],
   737=>[6597],
   721=>[5397],
   398=>[2098],
   428=>[1513],
   1141=>[2128],
   1315=>[6055],
   1575=>[8311],
   400=>[1354, 1356],
   1405=>[1388],
   700=>[984],
   712=>[486],
   1321=>[5297],
   1171=>[6122],
   1170=>[2593],
   1169=>[1675],
   1136=>[7488],
   853=>[6423],
   1724=>[8743],
   377=>[125],
   1043=>[3588],
   1044=>[3577],
   1045=>[3581],
   375=>[2025],
   378=>[131],
   1046=>[3589],
   708=>[2236],
   1059=>[3577],
   1060=>[3581],
   1103=>[4143],
   1070=>[2128],
   1071=>[2118],
   613=>[3538],
   1514=>[4962],
   1145=>[1674],
   1146=>[1673],
   1061=>[6174],
   1068=>[1667],
   1069=>[6055],
   1154=>[2131],
   998=>[2340],
   1150=>[2130],
   1149=>[1674],
   1202=>[3588],
   1062=>[6155],
   1208=>[2131],
   1063=>[3724],
   1155=>[6062],
   1190=>[2134],
   1206=>[3589],
   1198=>[3581],
   1289=>[198],
   295=>[21],
   1074=>[2106],
   273=>[23],
   1007=>[1354],
   965=>[3210],
   1075=>[2107],
   1411=>[1466],
   980=>[2130],
   36=>[1850],
   1604=>[9347],
   1104=>[1809],
   1373=>[1667],
   611=>[160],
   524=>[3736],
   523=>[2307],
   33=>[497],
   368=>[1972],
   1350=>[6895],
   1629=>[6512],
   1080=>[691],
   370=>[1974],
   713=>[2206],
   1005=>[6951],
   714=>[1757],
   1323=>[212],
   27=>[258],
   28=>[259],
   936=>[2429],
   475=>[2962],
   1319=>[3720],
   286=>[1318],
   1160=>[3581],
   1158=>[3588],
   1159=>[3577],
   1156=>[6055],
   1172=>[3675],
   1168=>[2131],
   45=>[498],
   50=>[280],
   34=>[870],
   1115=>[1667],
   1453=>[7879],
   35=>[223],
   1085=>[6058],
   522=>[5305],
   787=>[67],
   1082=>[2118],
   1454=>[817],
   1178=>[6055],
   1147=>[1667],
   1151=>[2130],
   1152=>[2128],
   1087=>[4954],
   1142=>[1673],
   1055=>[6977],
   1413=>[2118],
   1161=>[3589],
   1613=>[1673],
   1614=>[1675],
   1064=>[5299],
   1143=>[6062],
   1144=>[3588],
   1395=>[2616],
   1095=>[3131],
   1102=>[1939],
   1766=>[4195],
   1088=>[307],
   1090=>[1961],
   1091=>[3133],
   1162=>[6062],
   1163=>[6058],
   1164=>[6055],
   396=>[2103],
   1157=>[6066],
   1078=>[3152],
   1465=>[2128],
   1837=>[3577],
   536=>[4812],
   706=>[2131],
   1113=>[1667],
   397=>[2104, 2105],
   701=>[1667],
   1181=>[2118],
   1182=>[6062],
   1183=>[1674],
   1750=>[8743],
   264=>[403],
   895=>[6583],
   1111=>[3212],
   898=>[6584],
   951=>[6399],
   1424=>[2118],
   1615=>[2128],
   1107=>[1674],
   262=>[400],
   1427=>[392],
   1827=>[2188],
   1436=>[3610],
   1439=>[1710],
   1407=>[6423],
   379=>[132],
   1458=>[6055],
   1459=>[1673],
   445=>[646],
   1193=>[3577],
   1201=>[6062],
   1754=>[5471],
   1844=>[6073],
   1842=>[6058],
   430=>[2897],
   1338=>[1445],
   1222=>[357],
   1755=>[3919],
   1756=>[29],
   1174=>[1466],
   1616=>[2131],
   1627=>[6066],
   1209=>[6405],
   1210=>[6388],
   862=>[6388],
   1757=>[1553],
   1325=>[1667],
   1406=>[4040],
   915=>[6547],
   623=>[1449],
   1758=>[7130],
   1759=>[3577],
   860=>[4892],
   1351=>[5920],
   1324=>[2118],
   1327=>[6055],
   1027=>[1918, 1919, 1912, 1913, 1914, 1915, 1916, 1917],
   1316=>[6062],
   1367=>[3238],
   1467=>[6066],
   1625=>[1675],
   967=>[6358],
   1760=>[1671],
   1016=>[3682],
   1012=>[146],
   1017=>[1768],
   1015=>[2597],
   1018=>[6124, 6125, 6126, 6127],
   1220=>[33],
   1472=>[2130],
   598=>[2004],
   1013=>[1660],
   1030=>[2607],
   1019=>[2229, 2230, 2231],
   1014=>[3790],
   1031=>[3799],
   988=>[4700],
   984=>[4699],
   1026=>[1911],
   961=>[936],
   1028=>[981],
   1366=>[6046],
   1295=>[1017],
   1460=>[3581],
   1217=>[64, 65, 66],
   1488=>[5492],
   1218=>[5543],
   1216=>[5012],
   426=>[3110],
   1771=>[5471],
   1769=>[8190],
   1772=>[9351],
   1768=>[7103],
   1770=>[5511],
   293=>[952, 951, 947, 946],
   1484=>[3661],
   1838=>[3581],
   1504=>[8304],
   1332=>[6422],
   1474=>[301],
   1341=>[2134],
   1339=>[1710],
   616=>[1951],
   1034=>[1957],
   1352=>[5919],
   434=>[559],
   1001=>[7488],
   1485=>[2190],
   1221=>[354],
   689=>[3788],
   686=>[481],
   1312=>[3577],
   1778=>[3588],
   1337=>[2674],
   1346=>[4428],
   600=>[2674],
   1475=>[5471],
   1476=>[5495],
   1466=>[6062],
   1543=>[1673],
   1516=>[8667],
   1470=>[1674],
   1468=>[3588],
   1473=>[2131],
   1347=>[7129],
   1471=>[1675],
   1478=>[2131],
   1326=>[3577],
   1355=>[4587],
   1780=>[3581],
   1354=>[6895],
   1786=>[33],
   1414=>[2128],
   687=>[483],
   1358=>[3368],
   1357=>[3369],
   1463=>[1787],
   1479=>[321],
   1781=>[1362],
   1782=>[1361],
   1469=>[3589],
   1783=>[1361],
   1481=>[2869],
   1544=>[2128],
   1784=>[1361],
   1736=>[7124],
   1353=>[3531],
   1362=>[4470],
   1480=>[2368],
   1363=>[4630],
   1483=>[2369],
   1448=>[4217],
   699=>[5344],
   1365=>[4471],
   263=>[402],
   1795=>[844],
   1236=>[353],
   1375=>[6055],
   1376=>[1675],
   1788=>[900],
   1368=>[6949],
   1371=>[7018],
   697=>[5345],
   1369=>[6934],
   1521=>[1675],
   1534=>[6551],
   1535=>[3133],
   1536=>[4436],
   1537=>[7921],
   1487=>[3],
   1372=>[2118],
   1374=>[3577],
   1792=>[1675],
   1752=>[6258],
   1496=>[6062],
   1494=>[8209],
   1489=>[3996],
   989=>[3469],
   1531=>[33],
   1297=>[3491],
   1291=>[5113],
   1790=>[6066],
   1791=>[3589],
   1753=>[2469],
   1525=>[5471],
   1762=>[8759],
   1490=>[6945],
   1275=>[2623],
   1523=>[7124],
   1349=>[5516],
   1538=>[7922],
   1498=>[6055],
   1797=>[1673],
   1497=>[6058],
   1392=>[5174],
   1793=>[2131],
   1794=>[3638],
   1796=>[1674],
   1499=>[6066],
   604=>[2141],
   1799=>[1710],
   1798=>[1671],
   1630=>[4309],
   1508=>[9948],
   1423=>[166],
   1506=>[6062],
   1507=>[3581],
   1631=>[3070],
   1429=>[372, 373],
   1800=>[2130],
   1505=>[8302, 8303],
   1545=>[8918],
   1801=>[2128],
   1437=>[6055],
   1438=>[6073],
   1442=>[2134],
   1400=>[268],
   1402=>[1238],
   1403=>[6389],
   1440=>[5511],
   1419=>[6247],
   1513=>[8480],
   1512=>[4913],
   1511=>[7866],
   1344=>[3530],
   1491=>[8210],
   1526=>[5552],
   1509=>[7865],
   1191=>[1671],
   1345=>[3532],
   1510=>[7864],
   1607=>[6058],
   828=>[4478],
   1527=>[5495],
   1803=>[2134],
   1553=>[9945],
   1522=>[8644],
   1787=>[9355],
   1739=>[9134],
   1714=>[1674],
   1737=>[9128],
   1802=>[2122],
   1789=>[8859, 8860],
   1751=>[3610],
   1322=>[6984],
   1300=>[5494],
   1785=>[8165],
   1767=>[6465],
   1843=>[6055],
   1804=>[5540],
   1546=>[9058],
   1547=>[9050],
   1554=>[9089],
   1556=>[8887],
   1805=>[5259],
   1806=>[6789],
   1565=>[9125],
   1564=>[9118],
   973=>[6139],
   1847=>[8695],
   1849=>[831],
   1853=>[826],
   1589=>[1645],
   1548=>[9087],
   1555=>[8906],
   1568=>[8138],
   1562=>[9205],
   1563=>[9242],
   1558=>[9347],
   1566=>[9127],
   891=>[6826],
   1573=>[9300],
   395=>[1629],
   1738=>[1939],
   1812=>[9050],
   1813=>[2869],
   1851=>[7045],
   1664=>[3589],
   1808=>[515],
   1809=>[5988],
   1810=>[5965],
   1811=>[1306],
   1580=>[8665],
   1578=>[9179],
   1582=>[9171],
   1585=>[1667],
   1577=>[9129],
   1586=>[3577],
   1587=>[6055],
   1588=>[2118, 2119],
   1591=>[1674],
   1594=>[6062],
   1595=>[6058],
   1597=>[3581],
   1776=>[6058],
   1598=>[8655],
   1599=>[8669, 8672],
   1779=>[3577],
   1854=>[828],
   1856=>[6770],
   520=>[4526],
   1579=>[9242],
   1609=>[9347],
   1763=>[9392],
   1610=>[5878],
   1611=>[3581],
   1606=>[6062],
   1612=>[3619, 3589],
   1814=>[4508],
   1857=>[5276],
   1858=>[8734],
   1859=>[8735],
   1860=>[8100],
   1861=>[2379],
   1863=>[8101],
   1617=>[8542],
   1618=>[3568],
   1619=>[8541],
   1620=>[3570],
   1621=>[3567],
   1622=>[3566],
   1623=>[3569],
   1624=>[2131],
   1626=>[3589],
   1628=>[1648],
   1590=>[6602],
   533=>[1682],
   272=>[18],
   1840=>[6062],
   1774=>[5549],
   271=>[1],
   1865=>[547],
   1867=>[8084],
   1866=>[581],
   1864=>[8082],
   1868=>[582],
   1632=>[8399],
   763=>[6829],
   1633=>[8400],
   1807=>[5839],
   1815=>[4679],
   1816=>[4680],
   1817=>[6520],
   1818=>[4311],
   1870=>[8085],
   276=>[33],
   1204=>[2130],
   1819=>[7089],
   1820=>[6525],
   1359=>[3367],
   294=>[944],
   261=>[935],
   1821=>[9349],
   1356=>[4584],
   58=>[142],
   1634=>[1730],
   306=>[645],
   1822=>[5471],
   739=>[6828],
   1823=>[1],
   1835=>[3588],
   979=>[940],
   1824=>[8291],
   1825=>[2130],
   1869=>[5275],
   1831=>[1743],
   1871=>[2499],
   1862=>[580],
   1848=>[1531],
   1833=>[1671],
   1829=>[2134],
   1845=>[6120],
   307=>[646],
   1872=>[7071],
   1873=>[251],
   1877=>[3587],
   1884=>[7587],
   1885=>[9323],
   1886=>[6712],
   1887=>[6712],
   1888=>[6716],
   371=>[2024],
   1641=>[1346],
   1601=>[9394],
   354=>[944],
   1643=>[6066],
   1874=>[8618],
   1879=>[1738],
   1889=>[1947],
   1891=>[2183],
   1892=>[1076],
   1893=>[1738],
   1890=>[3131],
   1638=>[5939],
   1639=>[357],
   1640=>[355, 356],
   1238=>[5941],
   1875=>[5386],
   1642=>[3467],
   1608=>[592],
   1645=>[591],
   1646=>[2118],
   1648=>[3577],
   1649=>[2172],
   1644=>[1510],
   1876=>[6116],
   1878=>[3139],
   1880=>[674],
   1881=>[9302],
   1882=>[9282],
   1883=>[3138],
   625=>[3133],
   1096=>[4428],
   1097=>[6550],
   1570=>[9128],
   1108=>[3588],
   1571=>[9134],
   1101=>[5511],
   1098=>[4430],
   1832=>[1673],
   1894=>[1674],
   1895=>[1673],
   1836=>[3659],
   283=>[1547],
   1839=>[3610],
   1896=>[1671],
   1897=>[1710],
   1233=>[6120],
   1271=>[2706],
   673=>[5265],
   824=>[405],
   1241=>[1354],
   1265=>[7019],
   694=>[3104],
   858=>[1921],
   596=>[2493],
   909=>[7488],
   937=>[396],
   1290=>[260],
   568=>[1043],
   724=>[5268],
   1240=>[3060],
   477=>[3834],
   296=>[67],
   910=>[3060],
   342=>[313],
   341=>[1354],
   904=>[6547],
   1284=>[1017],
   903=>[6547],
   1286=>[4574],
   1294=>[2092],
   905=>[6422],
   720=>[4351],
   972=>[4131],
   719=>[3110],
   624=>[2684],
   1269=>[4108],
   268=>[1778],
   290=>[1354],
   569=>[3104],
   632=>[4052],
   685=>[4344],
   1270=>[2741],
   349=>[1332],
   427=>[2907],
   412=>[3105],
   1278=>[4893],
   746=>[6139],
   1292=>[4569],
   527=>[2907],
   1293=>[5646],
   288=>[1050],
   256=>[1354],
   440=>[1578],
   1263=>[1005],
   608=>[4251],
   489=>[889],
   601=>[2684],
   496=>[3104],
   462=>[4746],
   607=>[4195],
   417=>[3060],
   1262=>[5107],
   517=>[4195],
   756=>[5958],
   738=>[6833],
   762=>[5171],
   757=>[5958],
   1296=>[185],
   1008=>[3060],
   1539=>[7923],
   1540=>[7923],
   755=>[5958],
   1288=>[2738],
   386=>[370],
   1135=>[4131],
   381=>[134],
   338=>[323],
   325=>[1449],
   595=>[1532],
   1283=>[5648],
   1449=>[7464],
   1175=>[4052],
   1317=>[1354],
   1464=>[6139],
   1542=>[2234],
   1188=>[2684],
   1415=>[2684],
   968=>[7488],
   289=>[1332],
   570=>[4344],
   567=>[4195],
   1310=>[7488],
   1308=>[4131],
   1318=>[3060],
   1461=>[2234],
   1381=>[2842],
   1446=>[2842],
   1360=>[3060],
   962=>[404],
   1409=>[6422],
   1410=>[4052],
   1299=>[353],
   1482=>[8102],
   1268=>[1472],
   1388=>[324],
   1389=>[8046, 8047],
   1493=>[8211],
   1532=>[67],
   1898=>[2130],
   1390=>[8045],
   1495=>[8211],
   1394=>[5177, 5178],
   1391=>[5175],
   1387=>[339],
   1524=>[8190],
   1377=>[266, 267],
   1397=>[2684],
   1412=>[311],
   1393=>[5179],
   974=>[3690],
   1569=>[8137],
   718=>[1050],
   474=>[2772],
   1899=>[2128],
   1900=>[2122],
   1834=>[1710],
   1746=>[2040],
   1828=>[2122],
   1901=>[6882],
   1902=>[3551],
   1903=>[5884],
   1904=>[564],
   1905=>[5253],
   1906=>[5846],
   1907=>[5865],
   1908=>[6796],
   1909=>[6884],
   1910=>[565],
   1911=>[568],
   1912=>[5867],
   1913=>[5836],
   1914=>[5848],
   1915=>[566],
   1850=>[7045],
   557=>[4028]
  }
end
