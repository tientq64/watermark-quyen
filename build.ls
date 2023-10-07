require! {
   "fs-extra": fs
}

srcs = fs.readdirSync \photos
fs.writeJsonSync \srcs.json srcs
