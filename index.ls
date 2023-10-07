downloadBtnEl.disabled = yes

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

function getCoverRect img, index
   x = 0
   y = 0
   {width, height} = img
   ratio = width / height
   if index
      if ratio < 1
         x = 0
         y = height / 2 - width / 2
         height = width
         if index == 1
            offset = y * 0.67
         else if index == 2
            offset = y * 0.33
         if offset
            height += offset * 2
            y -= offset
      else
         x = width / 2 - height / 2
         y = 0
         width = height
         if index == 1
            offset = x * 0.67
         else if index == 2
            offset = x * 0.33
         if offset
            width += offset * 2
            x -= offset
   [x, y, width, height]

logo = await loadImg \logo.png

logoWidth = 160
logoHeight = 160

canvasWidth = 600
canvasHeight = 600

for let name in srcs
   img = await loadImg "photos/#name"
   x = 0
   y = 0
   width = img.width
   height = img.height
   ratio = width / height
   coverIndex = 0
   positionIndex = 0
   logoX = 0
   logoY = 0
   moving = no

   updateRect = !~>
      [x, y, width, height] := getCoverRect img, coverIndex

   updatePosition = !~>
      fracX = positionIndex % 5 / 4
      fracY = (Math.floor positionIndex / 5) / 4
      logoX := 10 + fracX * (canvasWidth - logoWidth - 20)
      logoY := 10 + fracY * (canvasHeight - logoHeight - 20)

   updateRect!
   updatePosition!

   canvas = document.createElement \canvas
   photosEl.appendChild canvas

   canvas.width = canvasWidth
   canvas.height = canvasHeight
   ctx = canvas.getContext \2d

   draw = !~>
      ctx.clearRect 0 0 canvasWidth, canvasHeight
      ctx.drawImage img, x, y, width, height, 0 0 canvasWidth, canvasHeight
      ctx.drawImage logo, logoX, logoY, logoWidth, logoHeight

   draw!

   canvas.addEventListener \pointerdown (event) !~>
      event.preventDefault!
      switch event.buttons
      | 1
         if event.ctrlKey
            if coverIndex
               canvas.setPointerCapture event.pointerId
               moving := yes
         else
            if event.shiftKey
               positionIndex += 5
            else
               positionIndex++
               if positionIndex % 5 == 0
                  positionIndex -= 5
            positionIndex %%= 25
            updatePosition!
            draw!
      | 4
         coverIndex++
         coverIndex := 0 if coverIndex == 4
         updateRect!
         draw!

   canvas.addEventListener \pointermove (event) !~>
      if moving
         if ratio < 1
            y -= event.movementY
         else
            x -= event.movementX
         draw!

   canvas.addEventListener \lostpointercapture (event) !~>
      if moving
         moving := no

downloadBtnEl.disabled = no

downloadBtnEl.addEventListener \click !~>
   zip = new JSZip

   for name, i in srcs
      blob = await new Promise (resolve) !~>
         photosEl.children[i]toBlob resolve, \image/jpeg
      zip.file name, blob

   blob = await zip.generateAsync do
      type: \blob
   url = URL.createObjectURL blob
   window.open url
   URL.revokeObjectURL url
