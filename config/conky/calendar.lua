require 'cairo'

function drawText(cr, x, y, text, size, opacity)
  font="Visitor TT2 BRK"
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

function drawCell(cr, x, y, isFilled)
  if isFilled then
    cairo_set_line_width(cr, 1)
    cairo_set_line_cap(cr, CAIRO_LINE_CAP_BUTT)
    cairo_set_source_rgba(cr,1,1,1,0.9)
    cairo_move_to(cr, x, y)
    cairo_line_to(cr, x + 5, y)
    cairo_line_to(cr, x + 5, y + 10)
    cairo_line_to(cr, x, y + 10)
    cairo_line_to(cr, x, y)
    cairo_stroke(cr)
  end
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

  drawText(cr, conky_window.width - 220, 70, os.date("%H:%M"), 100, 0.6)
  drawText(cr, conky_window.width - 70, 100, os.date("%S"), 50, 0.4)

  seconds = tonumber(os.date("%S"))

  for i=0,14 do
    drawCell(cr, conky_window.width - 220 + i * 10, 15, seconds > 4 * i)
  end

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
