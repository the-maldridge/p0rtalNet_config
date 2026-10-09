locals {
  switches = {
    backboard0 = {
      trunks = {
        trk1 = { members = formatlist("%s", [9, 10]) }
      }
      vlans = {
        res      = { id = 10, name = "Residential", is_primary = true }
        iot      = { id = 25, name = "IoT" }
        mgmt     = { id = 99, name = "Management", is_mgmt = true, use_dhcp = true }
        peer     = { id = 101, name = "Internal Peering" }
        frontier = { id = 110, name = "frontier-uplink" }
      }
      interfaces = {
        1  = { name = "res-scratch1", untagged = "res" }
        2  = { name = "res-scratch2", untagged = "res" }
        3  = { name = "res-scratch3", untagged = "res" }
        4  = { name = "peer-sneakynet", untagged = "peer" }
        5  = { name = "1stfloor-eaves", untagged = "iot" }
        6  = { name = "opensprinkler", untagged = "iot" }
        8  = { name = "frontier-ont", untagged = "frontier" }
        9  = { name = "trk1-p0" }
        10 = { name = "trk1-p1" }
      }
    }

    coresw0 = {
      trunks = {
        trk1 = { members = formatlist("%s", [49, 50]) }
        trk2 = { members = formatlist("%s", [11, 12]) }
      }
      vlans = {
        res      = { id = 10, name = "Residential", is_primary = true }
        guest    = { id = 15, name = "Guest" }
        svcs     = { id = 20, name = "Services" }
        iot      = { id = 25, name = "IoT" }
        tel      = { id = 30, name = "Telephony" }
        dmz      = { id = 35, name = "DMZ" }
        mgmt     = { id = 99, name = "Management", is_mgmt = true, use_dhcp = true }
        peer     = { id = 101, name = "Internal Peering" }
        frontier = { id = 110, name = "Frontier Upstream" }
      }
      interfaces = {
        1  = { name = "hass", untagged = "svcs" }
        5  = { name = "angzarr", untagged = "res" }
        9  = { name = "workdesk", untagged = "res" }
        11 = { name = "leafsw1-leg1" }
        12 = { name = "leafsw1-leg2" }
        15 = { name = "supernode", untagged = "res" }
        16 = { name = "brother-laser", untagged = "svcs" }
        17 = { name = "banister", untagged = "iot" }
        19 = { name = "nightsky", untagged = "res" }
        21 = { name = "floor2-ts", untagged = "iot" }
        22 = { name = "floor2-eaves", untagged = "iot" }
        25 = { name = "lr-tv", untagged = "res" }
        29 = { name = "floor1-ts", untagged = "iot" }
        30 = { name = "kitchen-trmnl", untagged = "res" }
        32 = { name = "kitchen-srvr", untagged = "mgmt" }
        33 = { name = "kitchen-uplights", untagged = "iot" }
        34 = { name = "tv-couch", untagged = "res" }
        37 = { name = "tv-stargazer", untagged = "res" }
        47 = { name = "cap1", untagged = "mgmt", tagged = ["res", "guest", "iot"] }
        48 = { name = "cap2", untagged = "mgmt", tagged = ["res", "guest", "iot"] }
        49 = { name = "Trk1-Leg1" }
        50 = { name = "Trk1-Leg2" }
        51 = { name = "gdesk01", tagged = ["res", "guest", "svcs", "iot", "tel", "dmz"] }
      }
    }

    compute0 = {
      trunks = {
        trk1 = { members = formatlist("%s", [27, 28]) }
        trk2 = { members = formatlist("%s", [3, 4]) }
      }
      vlans = {
        res   = { id = 10, name = "Residential", is_primary = true }
        guest = { id = 15, name = "Guest" }
        svcs  = { id = 20, name = "Services" }
        iot   = { id = 25, name = "IoT" }
        tel   = { id = 30, name = "Telephony" }
        dmz   = { id = 35, name = "DMZ" }
        mgmt  = { id = 99, name = "Management", is_mgmt = true, use_dhcp = true }
        peer  = { id = 101, name = "Internal Peering" }
      }
      interfaces = {
        1  = { name = "globaldynamics", tagged = ["res", "guest", "svcs", "iot", "tel", "dmz", "mgmt"] }
        2  = { name = "deep-thought", tagged = ["res", "guest", "svcs", "iot", "tel", "dmz", "mgmt"] }
        3  = { name = "SaltMine-Leg1" }
        4  = { name = "SaltMine-Leg2" }
        20 = { name = "net-dock1", untagged = "peer" }
        22 = { name = "ups0", untagged = "mgmt" }
        23 = { name = "DLLSTXPO01T", untagged = "tel" }
        24 = { name = "DLLSTXPO01DS0`", untagged = "tel" }
        27 = { name = "trk1-leg1" }
        28 = { name = "trk1-leg2" }
      }
    }

    leafsw1 = {
      trunks = {
        trk1 = { members = formatlist("%s", [9, 10]) }
      }
      vlans = {
        res  = { id = 10, name = "Residential", is_primary = true }
        mgmt = { id = 99, name = "Management", is_mgmt = true, use_dhcp = true }
      }
      interfaces = {
        6  = { name = "res-tail", untagged = "res" }
        7  = { name = "res-tail", untagged = "res" }
        8  = { name = "theGibson", untagged = "res", tagged = ["mgmt"] }
        9  = { name = "trk1-p0" }
        10 = { name = "trk1-p1" }
      }
    }
  }
}

module "switch" {
  source = "${path.module}/switch"

  hostname   = terraform.workspace
  trunks     = local.switches[terraform.workspace].trunks
  vlans      = local.switches[terraform.workspace].vlans
  interfaces = local.switches[terraform.workspace].interfaces
}
