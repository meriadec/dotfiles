local gears = require("gears")
local cairo = require("lgi").cairo
local awful = require("awful")
local wibox = require("wibox")

local HIDPI = os.getenv("HIDPI") == "1"

local smartBorders = {}

local GUTTER = 10
local WEIGHT = 3
local ARROW_WEIGHT = 40
local ARROW_WIDTH = 100
local COLOR = gears.color("#2b303b")

if HIDPI then
  GUTTER = 25
  WEIGHT = 10
  STRING_WEIGHT = 4
  ARROW_WEIGHT = 100
  ARROW_WIDTH = 40
end

function smartBorders.set(c, firstRender)

  local b_weight = WEIGHT
  local b_string_weight = STRING_WEIGHT
  local b_gutter = GUTTER
  local b_arrow = ARROW_WEIGHT

  if c.floating then
    b_weight = 0
    b_string_weight = 0
    b_gutter = 0
    b_arrow = 0
  end

  local side = b_weight + b_gutter
  local total_width = c.width
  local total_height = c.height

  -- for some reasons, the client height/width are not the same at first
  -- render (when called by request title bar) and when resizing
  if firstRender then
    total_width = total_width + 2 * (b_weight + b_gutter)
  else
    total_height = total_height - 2 * (b_weight + b_gutter)
  end

  local imgTop = cairo.ImageSurface.create(cairo.Format.ARGB32, total_width, side)
  local crTop  = cairo.Context(imgTop)

  crTop:set_source(COLOR)
  crTop:rectangle(0, b_weight / 2 - b_string_weight / 2, total_width, b_string_weight)
  crTop:fill()

  crTop:set_source(COLOR)
  crTop:rectangle(0, 0, b_arrow, b_weight)
  crTop:rectangle(0, 0, b_weight, side)
  crTop:rectangle(total_width - b_arrow, 0, b_arrow, b_weight)
  crTop:rectangle(total_width - b_weight, 0, b_weight, side)
  crTop:fill()

  local imgBot = cairo.ImageSurface.create(cairo.Format.ARGB32, total_width, side)
  local crBot  = cairo.Context(imgBot)

  crBot:set_source(COLOR)
  crBot:rectangle(0, side - b_weight / 2 - b_string_weight / 2, total_width, b_string_weight)
  crBot:fill()

  crBot:set_source(COLOR)
  crBot:rectangle(0, b_gutter, b_arrow, b_weight)
  crBot:rectangle(0, 0, b_weight, side)
  crBot:rectangle(total_width - b_weight, 0, b_weight, side)
  crBot:rectangle(total_width - b_arrow, b_gutter, b_arrow, b_weight)
  crBot:fill()

  local imgLeft = cairo.ImageSurface.create(cairo.Format.ARGB32, side, total_height)
  local crLeft  = cairo.Context(imgLeft)

  crLeft:set_source(COLOR)
  crLeft:rectangle(b_weight / 2 - b_string_weight / 2, 0, b_string_weight, total_height)
  crLeft:fill()

  crLeft:set_source(COLOR)
  crLeft:rectangle(0, 0, b_weight, b_arrow - side)
  crLeft:rectangle(0, total_height - b_arrow + side, b_weight, b_arrow - side)
  crLeft:fill()

  local imgRight = cairo.ImageSurface.create(cairo.Format.ARGB32, side, total_height)
  local crRight  = cairo.Context(imgRight)

  crRight:set_source(COLOR)
  crRight:rectangle(b_gutter + b_weight / 2 - b_string_weight / 2, 0, b_string_weight, total_height)
  crRight:fill()

  crRight:set_source(COLOR)
  crRight:rectangle(b_gutter, 0, b_weight, b_arrow - side)
  crRight:rectangle(b_gutter, total_height - b_arrow + side, b_weight, b_arrow - side)
  crRight:fill()

  awful.titlebar(c, {
    size = b_weight + b_gutter,
    position = "top",
    bg_normal = "transparent",
    bg_focus = "transparent",
    bgimage_focus = imgTop,
  }) : setup { layout = wibox.layout.align.horizontal, }

  awful.titlebar(c, {
    size = b_weight + b_gutter,
    position = "left",
    bg_normal = "transparent",
    bg_focus = "transparent",
    bgimage_focus = imgLeft,
  }) : setup { layout = wibox.layout.align.horizontal, }

  awful.titlebar(c, {
    size = b_weight + b_gutter,
    position = "right",
    bg_normal = "transparent",
    bg_focus = "transparent",
    bgimage_focus = imgRight,
  }) : setup { layout = wibox.layout.align.horizontal, }

  awful.titlebar(c, {
    size = b_weight + b_gutter,
    position = "bottom",
    bg_normal = "transparent",
    bg_focus = "transparent",
    bgimage_focus = imgBot,
  }) : setup { layout = wibox.layout.align.horizontal, }

end

-- TODO: finish that shit

function createFragment(c, position)

  local img = cairo.ImageSurface.create(
    cairo.Format.ARGB32,
    c.width + GUTTER + WEIGHT,
    c.height + GUTTER + WEIGHT
  )

  local ctx  = cairo.Context(img)
  ctx:set_source(COLOR)

  if position == "top" then
    ctx:rectangle(0, 0, c.width + GUTTER + WEIGHT, WEIGHT)
    ctx:rectangle(0, 0, ARROW_WIDTH, ARROW_WEIGHT)
    ctx:rectangle(0, 0, ARROW_WEIGHT, WEIGHT + GUTTER)
  elseif position == "left" then
    ctx:rectangle(0, 0, WEIGHT, c.height + GUTTER + WEIGHT)
    ctx:rectangle(0, 0, ARROW_WEIGHT, ARROW_WIDTH - GUTTER - WEIGHT)
    ctx:rectangle(0, c.height - ARROW_WIDTH - GUTTER - WEIGHT, ARROW_WEIGHT, ARROW_WIDTH - GUTTER - WEIGHT)
  elseif position == "bottom" then
    ctx:rectangle(0, GUTTER, c.width + GUTTER + WEIGHT, WEIGHT)
    ctx:rectangle(0, 0, ARROW_WEIGHT, GUTTER)
    ctx:rectangle(0, GUTTER - ARROW_WEIGHT, ARROW_WIDTH, ARROW_WEIGHT)
  end

  ctx:fill()

  awful.titlebar(c, {
    size = GUTTER + WEIGHT,
    position = position,
    bg_normal = "transparent",
    bg_focus = "transparent",
    bgimage_focus = img,
  }) : setup { layout = wibox.layout.align.horizontal, }

end

return smartBorders
