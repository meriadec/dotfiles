require 'cairo'

function drawText(cr, x, y, text, size, opacity)
  font="Visitor TT1 BRK"
  font_size=size
  red,green,blue,alpha=1,1,1,opacity
  font_slant=CAIRO_FONT_SLANT_NORMAL
  font_face=CAIRO_FONT_WEIGHT_NORMAL
  cairo_select_font_face (cr, font, font_slant, font_face);
  cairo_set_font_size (cr, font_size)
  cairo_set_source_rgba (cr,red,green,blue,alpha)
  cairo_move_to (cr,x, y)
  cairo_show_text (cr,text)
  cairo_stroke (cr)
end

function drawCircle(cr, x, y, width, value, label)
  --SETTINGS
  --rings size
  ring_center_x=x
  ring_center_y=y
  ring_radius=width / 2
  ring_width=3
  --colors
  --set background colors, 1,0,0,1 = fully opaque red
  ring_bg_red=1
  ring_bg_green=1
  ring_bg_blue=1
  ring_bg_alpha=0.3
  --set indicator colors, 1,1,1,1 = fully opaque white
  ring_in_red=1
  ring_in_green=1
  ring_in_blue=1
  ring_in_alpha=0.5
  --indicator value settings
  max_value=100

  cairo_set_line_width (cr,ring_width)
  cairo_set_source_rgba (cr,ring_bg_red,ring_bg_green,ring_bg_blue,ring_bg_alpha)
  cairo_arc (cr,ring_center_x,ring_center_y,ring_radius,0,2*math.pi)
  cairo_stroke (cr)

  cairo_set_line_width (cr,ring_width)
  cairo_set_source_rgba (cr,ring_bg_red,ring_bg_green,ring_bg_blue,0.06)
  cairo_arc (cr,ring_center_x,ring_center_y,ring_radius + 5,0,2*math.pi)
  cairo_stroke (cr)

  cairo_set_line_width (cr,20)
  end_angle=value*(360/max_value)
  cairo_set_source_rgba (cr,ring_in_red,ring_in_green,ring_in_blue,0.3)
  cairo_arc (cr,ring_center_x,ring_center_y,ring_radius - 15,(-90)*(math.pi/180),(end_angle-90)*(math.pi/180))
  cairo_stroke (cr)

  cairo_set_line_width (cr,3)
  end_angle=value*(360/max_value)
  cairo_set_source_rgba (cr,ring_in_red,ring_in_green,ring_in_blue,ring_in_alpha)
  cairo_arc (cr,ring_center_x,ring_center_y,ring_radius - 7,(-90)*(math.pi/180),(end_angle-90)*(math.pi/180))
  cairo_stroke (cr)

  padded_value = tostring(value)
  if string.len(padded_value) == 1 then
    padded_value = "0" .. padded_value
  end

  drawText(cr, x - 4 * (string.len(label) + 3) / 2, y + 10, label, 18, 0.4)
end

function conky_main()

  if conky_window == nil then
    return
  end

  local cs = cairo_xlib_surface_create(
    conky_window.display,
    conky_window.drawable,
    conky_window.visual,
    conky_window.width,
    conky_window.height
  )

  cr = cairo_create(cs)

  cpu=conky_parse("${cpu}")
  drawCircle(cr, 120, 120, 200, cpu, "CPU")

  mem=conky_parse("${memperc}")
  drawCircle(cr, 300, 100, 140, mem, "MEM")

  -- cairo_set_line_width(cr, 4)
  -- cairo_set_line_cap(cr, CAIRO_LINE_CAP_BUTT)
  -- cairo_set_source_rgba(cr,1,1,1,1)
  -- cairo_move_to(cr, 0, 0)
  -- cairo_line_to(cr, conky_window.width, 100)
  -- cairo_stroke(cr)

  -- ==============================
  cairo_destroy(cr)
  cairo_surface_destroy(cs)
  cr=nil
end
