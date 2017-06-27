#ifndef SENDER_DATA_H
#define SENDER_DATA_H

#define READINGS_SIZE 1000

uint16_t jogDataX[READINGS_SIZE] = {2523, 2515, 2055, 2267, 2379, 2183, 2003,
                                    1891, 2143, 2223, 2347, 2143, 1831, 2035,
                                    2171, 2395, 2203, 2307, 2259, 2335, 2371,
                                    2427, 2303, 2363, 2291, 2115, 2075, 2239,
                                    2299, 2299, 2219, 2479, 2531, 2175, 1979,
                                    2051, 2155, 2175, 1431, 2083, 2371, 2563,
                                    2635, 2267, 1911, 1951, 2163, 2267, 1891,
                                    1791, 2219, 2375, 2447, 2415, 2199, 2003,
                                    2091, 2143, 2171, 1919, 2223, 2295, 2391,
                                    2451, 2359, 1919, 2147, 2279, 2315, 1867,
                                    2147, 2435, 2547, 2523, 1951, 2067, 2247,
                                    2315, 2103, 2131, 2311, 2343, 2447, 2475,
                                    2519, 2227, 1823, 2139, 2171, 2315, 2007,
                                    1807, 2307, 2419, 2527, 2007, 1823, 2231,
                                    2459, 1903, 1451, 2079, 2435, 2363, 2407,
                                    2339, 2475, 2011, 2007, 1763, 1807, 2067,
                                    2259, 2227, 2227, 1971, 1467, 1527, 2219,
                                    2283, 1927, 2475, 2231, 2327, 1695, 1563,
                                    2275, 2863, 2335, 2059, 1915, 2123, 1859,
                                    2231, 1883, 1999, 2195, 2415, 2507, 2547,
                                    1919, 1779, 2139, 2195, 2291, 2331, 2048,
                                    1603, 2095, 2667, 2731, 2459, 2159, 2111,
                                    2031, 2235, 2347, 1871, 1559, 1851, 2631,
                                    2635, 2619, 2335, 2111, 2175, 2179, 2111,
                                    2103, 2239, 1791, 1747, 2163, 2563, 2587,
                                    2575, 1963, 1903, 2007, 2035, 2191, 2311,
                                    1823, 2259, 2643, 2771, 2435, 2219, 2251,
                                    2051, 2239, 1991, 1939, 1999, 2343, 2571,
                                    2583, 2367, 2183, 2011, 2151, 2295, 2251,
                                    2027, 2455, 2711, 2631, 2499, 2323, 1803,
                                    1915, 2291, 2247, 2307, 2379, 2355, 1967,
                                    1923, 2347, 2495, 2699, 2503, 2387, 2571,
                                    2259, 2103, 2259, 2063, 2135, 2211, 2235,
                                    2735, 2419, 2227, 2123, 2099, 2255, 2387,
                                    2287, 2243, 2087, 1527, 2435, 2763, 2275,
                                    1947, 1963, 1927, 2219, 2303, 1835, 2346,
                                    2779, 2623, 2127, 1623, 1971, 2339, 2139,
                                    2179, 2415, 2675, 2587, 2219, 2011, 1991,
                                    1927, 1955, 2267, 2279, 2243, 1915, 2831,
                                    2667, 2383, 2083, 1867, 2175, 2219, 2279,
                                    2295, 2067, 1631, 1903, 2427, 2763, 2675,
                                    2411, 2351, 2303, 2287, 2259, 2263, 2099,
                                    2183, 2579, 2755, 2603, 2491, 2327, 2339,
                                    2435, 2463, 2283, 2079, 2071, 2331, 2415,
                                    2479, 2551, 2439, 2527, 2383, 2251, 2235,
                                    2291, 2327, 2175, 2075, 2259, 2399, 2451,
                                    2511, 2599, 2495, 1711, 1495, 2087, 2051,
                                    2083, 1707, 1855, 2163, 2363, 2387, 2443,
                                    1967, 1423, 1959, 2367, 2243, 2223, 1787,
                                    1091, 1907, 2263, 2507, 2519, 2759, 1059,
                                    1319, 2531, 2603, 2351, 2019, 1507, 1971,
                                    2503, 1795, 1479, 1919, 2399, 1995, 1883,
                                    1635, 1671, 2303, 2543, 2595, 2471, 1715,
                                    1075, 1302, 1867, 1795, 1695, 1763, 1550,
                                    2323, 2343, 2287, 1335, 1935, 2179, 1911,
                                    1499, 1807, 2011, 2619, 2675, 2635, 2003,
                                    1423, 1871, 2159, 1975, 1627, 1971, 2423,
                                    2603, 2515, 1507, 1823, 1907, 2071, 2115,
                                    2075, 1331, 1555, 2083, 2671, 2331, 2175,
                                    2343, 2115, 1278, 1891, 2391, 2635, 2603,
                                    2471, 1699, 1351, 2251, 2371, 2299, 2351,
                                    2311, 2015, 1983, 2371, 2307, 1482, 2199,
                                    2679, 2583, 1967, 1631, 1719, 2099, 2187,
                                    2007, 1947, 1626, 1771, 2135, 2583, 2667,
                                    2183, 1543, 1511, 1699, 2255, 2151, 1599,
                                    1951, 2483, 2531, 2671, 2567, 1471, 1195,
                                    2407, 2507, 2427, 2015, 1763, 2303, 2519,
                                    2767, 2475, 1463, 1367, 1975, 2319, 2419,
                                    2351, 1167, 1935, 2467, 2603, 2455, 1087,
                                    1635, 2339, 2295, 1919, 1391, 2255, 2419,
                                    2627, 2555, 1803, 1150, 1323, 1915, 2183,
                                    2303, 2391, 1651, 1118, 1671, 2407, 2635,
                                    2615, 1591, 1419, 1611, 2035, 2395, 2031,
                                    1339, 1967, 2307, 2579, 2763, 2199, 1679,
                                    1395, 1855, 2103, 2171, 2199, 1951, 1863,
                                    2383, 2399, 2615, 2651, 1715, 1755, 2007,
                                    2267, 2111, 1419, 1279, 2579, 2435, 2119,
                                    2251, 2119, 1447, 1763, 2631, 2583, 2263,
                                    1959, 1651, 2227, 2207, 1503, 1779, 2343,
                                    2571, 2419, 1919, 1651, 1707, 2083, 2243,
                                    2115, 1979, 1751, 1755, 2063, 2291, 2611,
                                    2611, 1959, 1651, 1687, 2251, 2347, 1199,
                                    1787, 1855, 2411, 2507, 2647, 2515, 2271,
                                    1591, 1559, 1923, 2267, 2407, 1795, 1495,
                                    2355, 2599, 2675, 1591, 1266, 2171, 2131,
                                    2259, 1186, 2171, 2427, 2851, 2831, 2019,
                                    1959, 2235, 2231, 2048, 1691, 2227, 2543,
                                    2651, 2351, 1535, 1639, 2167, 2351, 2087,
                                    1599, 2251, 2455, 2491, 2379, 1727, 2087,
                                    2167, 2151, 2127, 1759, 1631, 2339, 2651,
                                    2607, 2059, 1711, 1731, 2007, 2339, 1671,
                                    1739, 2175, 2483, 2507, 2475, 2343, 2407,
                                    2327, 2123, 2139, 1947, 1775, 2619, 2951,
                                    2231, 1991, 1655, 2059, 2203, 2203, 2307,
                                    1179, 1955, 2327, 2671, 2307, 1631, 1575,
                                    1803, 2139, 2155, 2087, 1703, 1607, 1703,
                                    2359, 2703, 2383, 1831, 1567, 2235, 2119,
                                    2179, 1391, 1635, 2259, 2611, 2663, 2327,
                                    1971, 1707, 1819, 2049, 2015, 1971, 1719,
                                    1499, 2235, 2635, 2551, 2019, 1555, 1091,
                                    1923, 2227, 2447, 2427, 1214, 1895, 2451,
                                    2595, 2095, 1719, 1899, 2443, 1883, 1379,
                                    1811, 2379, 2627, 2455, 1947, 1639, 2147,
                                    2187, 1907, 1603, 1427, 2571, 2591, 1791,
                                    1491, 2191, 2263, 2175, 1022, 2295, 2671,
                                    2699, 2151, 2219, 1987, 1519, 1895, 2243,
                                    2607, 2507, 1699, 2283, 2283, 2343, 2355,
                                    2395, 2351, 2263, 1859, 1859, 2119, 2283,
                                    2451, 2543, 2387, 2263, 2335, 2259, 2203,
                                    2039, 2031, 2163, 2395, 2403, 2095, 1995,
                                    1979, 2431, 2203, 2003, 2123, 2287, 2291,
                                    1635, 2147, 2471, 2695, 2555, 1883, 1995,
                                    2403, 1923, 2571, 2499, 2455, 1871, 1351,
                                    2151, 2267, 2383, 2183, 1403, 1975, 2347,
                                    2575, 2435, 1847, 2023, 2035, 2335, 1547,
                                    1539, 2419, 2643, 2295, 1943, 1851, 2095,
                                    2259, 2419, 1943, 1527, 2227, 2611, 2823,
                                    1915, 1579, 2111, 2239, 2351, 1847, 1554,
                                    1955, 2567, 2783, 2679, 1995, 1663, 1771,
                                    2371, 2443, 1482, 2011, 2699, 2571, 1487,
                                    1843, 2155, 2339, 1447, 1435, 2151, 2311,
                                    2351, 2387, 2311, 2247, 1971, 1795, 2048,
                                    2167, 2395, 2559, 2035, 2011, 2163, 2363,
                                    2531, 2379, 1827, 2275, 2447, 2167, 2027,
                                    1991, 2251, 2559, 2507, 1927, 1983, 1991,
                                    2299, 2383, 2055, 1955, 2679, 2563, 1935,
                                    1887, 1895, 2219, 2267, 2227, 2059, 1555,
                                    2511, 2715, 2451, 1731, 1667, 2131, 2143,
                                    2351, 2343, 1831, 1635, 2519, 2603, 2527,
                                    1923, 1851, 1939, 2143, 2343, 2083, 2203,
                                    2515, 2571, 1823, 1747, 2071, 2099, 2187,
                                    2347, 1859, 1655, 2131, 2363, 1931, 2103,
                                    2167, 2411, 2059, 1959, 2183, 2551, 2611,
                                    1847, 2131, 2351, 2303, 2007, 1991, 2439,
                                    2499, 2519, 1867, 1871, 2339, 2375, 2263,
                                    2143, 1751, 2179, 2355, 2327, 2311, 2287,
                                    2355, 2379, 2291, 2059, 2067, 2467, 2563,
                                    2459, 2167, 2123, 2239, 2535, 2035, 2027,
                                    2135, 2291, 2379, 2167, 2183, 2383, 2555,
                                    2331, 2043, 2183, 2311, 2331, 1895, 2195,
                                    2535, 2667, 2327, 1963, 2067, 2039, 2023,
                                    2147, 2251, 2643, 2603, 1875, 2099, 2319,
                                    2139, 2251, 2715, 2383, 2211, 1995};

#endif