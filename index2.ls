srcs = await (await fetch \srcs.json)json!
# srcs .= slice 0 18

function loadImg src
   new Promise (resolve) !~>
      img = new Image
      img.src = src
      img.onload = !~>
         resolve img

function clamp num, min, max
   if num < min => min
   else if num > max => max
   else num

logo = await loadImg \logo.png

for src in srcs
   img = await loadImg src
   {width, height} = img
   ratio = width / height
   if ratio < 1
      x = 0
      y = height / 2 - width / 2
      height = width
   else
      x = width / 2 - height / 2
      y = 0
      width = height

   canvas = document.createElement \canvas
   photosEl.appendChild canvas

   canvas.width = 300
   canvas.height = 300
   ctx = canvas.getContext \2d
   ctx.drawImage img, x, y, width, height, 0 0 300 300
   # ctx.drawImage logo, 10 0 140 140

   px = 8

   canvas2 = document.createElement \canvas
   canvas2.width = px
   canvas2.height = px
   ctx2 = canvas2.getContext \2d
   ctx2.imageSmoothingEnabled = yes
   ctx2.drawImage canvas, 0 0 px, px

   {data} = ctx2.getImageData 0 0 px, px
   bri = 0
   for i til data.length / 4
      j = i * 4
      x2 = i % px
      y2 = Math.floor i / px
      r = data[j + 0]
      g = data[j + 1]
      b = data[j + 2]
      bri2 = (r + g + b) / 3
      if bri < bri2
         bri = bri2
         x = x2
         y = y2

   pxx = 300 / px / 2
   x = x / px * 300 + pxx
   y = y / px * 300 + pxx
   x -= 70
   y -= 70
   right = 300 - 140
   x = clamp x, 0 right
   y = clamp y, 0 right
   ctx.drawImage logo, x, y, 140 140
