import math
import re


# Representative regional centers map field coordinates to PSA's regional data.
REGION_CENTERS = {
    "CORDILLERA ADMINISTRATIVE REGION (CAR)": (16.41639, 120.59306),
    "REGION I (ILOCOS REGION)": (16.61591, 120.31663),
    "REGION II (CAGAYAN VALLEY)": (17.61577, 121.72285),
    "REGION III (CENTRAL LUZON)": (15.03425, 120.68445),
    "REGION IV-A (CALABARZON)": (14.21167, 121.16528),
    "MIMAROPA REGION": (13.41170, 121.18030),
    "REGION V (BICOL REGION)": (13.14125, 123.74073),
    "REGION VI (WESTERN VISAYAS)": (10.69694, 122.56444),
    "NEGROS ISLAND REGION": (9.30646, 123.30769),
    "REGION VII (CENTRAL VISAYAS)": (10.31672, 123.89071),
    "REGION VIII (EASTERN VISAYAS)": (11.24333, 125.00472),
    "REGION IX (ZAMBOANGA PENINSULA)": (7.82570, 123.43700),
    "REGION X (NORTHERN MINDANAO)": (8.48222, 124.64722),
    "REGION XI (DAVAO REGION)": (7.07306, 125.61278),
    "REGION XII (SOCCSKSARGEN)": (6.50306, 124.84694),
    "REGION XIII (CARAGA)": (8.94917, 125.54361),
    "BANGSAMORO AUTONOMOUS REGION IN MUSLIM MINDANAO (BARMM)": (
        7.22361,
        124.24639,
    ),
}


def normalize_psa_region(value: str) -> str | None:
    if not value.startswith("..") or value.startswith("...."):
        return None

    name = value[2:].strip()
    name = re.sub(r"[a-z]/$", "", name).strip()
    name = name.upper()
    return name if name in REGION_CENTERS else None


def nearest_region(latitude: float, longitude: float) -> str:
    def distance_squared(center: tuple[float, float]) -> float:
        center_lat, center_lon = center
        lat_scale = math.cos(math.radians((latitude + center_lat) / 2))
        return (latitude - center_lat) ** 2 + (
            (longitude - center_lon) * lat_scale
        ) ** 2

    return min(REGION_CENTERS, key=lambda region: distance_squared(REGION_CENTERS[region]))
