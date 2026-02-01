function hit(p1, p2)
  return p1.x==p2.x and p1.y==p2.y
end

function generate_fruit()
  -- The fruit kind is used also to determine its sprite
  fruit={}
  fruit.kind = red_fruit_sprite -- the default
  golden_fruit_counter = 0
  if score > 0 and score % 9 == 0 then
    -- Sometimes a golden fruit might be generated
    if (flr(rnd(9)) +1) % 3 == 0 then
      fruit.kind = golden_fruit_sprite
      golden_fruit_counter = 150 -- Roughly 5 seconds to get the golden fruit
    end
  end
  local gen_pos = function()
    -- Randomizes the position of the next fruit
    -- Each game cell is 8 pixels wide and tall
    -- The border cells (Those that contain x/y at value 0/127) should be excluded
    fruit.x=(flr(rnd(13)) + 1)*8
    fruit.y=(flr(rnd(13)) + 1)*8
  end
  local check_pos = function()
    -- Checks whether the generated position overlaps the snake or a wall
    if hit(fruit, head) then return true end
    for i=1, #tail do
      if hit(fruit, tail[i]) then return true end
    end
    for i=1, #walls do
      if hit(fruit, walls[i]) then return true end
    end
    return false 
  end
  gen_pos()
  while check_pos() do
    gen_pos()
  end
end

function init_game(level)
  in_game = true
  gameover = false

  head={x=16, y=32}
  tail={}
  add(tail, {x=16,y=24})
  add(tail, {x=24,y=24})
  add(tail, {x=32,y=24})
  snake_direction={x=0, y=8}
  speed=11
  move_counter=0
  score=0

  walls={} -- level 1
  if level == 2 then
    for i=0,120,8 do
      -- top line of walls
      add(walls, {x=i, y=gameboard.top})
    end
    for i=0,120,8 do
      -- bottom line of walls
      add(walls, {x=i, y=gameboard.bottom-7})
    end
  elseif level == 3 then
    for i=0,120,8 do
      -- top line of walls
      add(walls, {x=i, y=gameboard.top})
    end
    for i=0,120,8 do
      -- bottom line of walls
      add(walls, {x=i, y=gameboard.bottom-7})
    end
    for i=8,112,8 do
      -- left line of walls
      add(walls, {x=gameboard.left, y=i})
    end
    for i=8,112,8 do
      -- right line of walls
      add(walls, {x=gameboard.right-7, y=i})
    end
  elseif level == 4 then

  end

  generate_fruit()
end

function _init()
  -- Graphics definitions
  logo_sprite=10
  snake_head_h_sprite = 0
  snake_head_v_sprite = 7
  snake_body_h_sprite = 1
  snake_body_v_sprite = 6
  snake_body_d_sprite = 4
  snake_tail_h_sprite = 8
  snake_tail_v_sprite = 9
  red_fruit_sprite = 2
  golden_fruit_sprite = 3
  wall_sprite = 5
  header_color = 1 -- dark blue
  bg_color = 11 -- light green
  header_rect={left=0, top=0, right=127, bottom=7}

  -- Menu
  menu = {
    elements={"easy", "medium", "hard", "labirinth"},
    selected=1,
    bg_col=11, -- light green
    bg_sel_col=11,
    font_col=1, -- dark blue
    font_sel_col=8 -- red
  }

  -- Game components
  gameboard={left= 0, top=8, right=127, bottom=127}
  gameover = false
  in_game = false
end

function copy_pos(source, dest)
  dest.x = source.x
  dest.y = source.y
end

function update_game()
  if gameover then
    snake_direction={x=0, y=0}
    return
  end
  -- check input
  -- If a button is pressed, it changes direction
  -- only if there is not a tail block in the next cell
  -- the head should go
  --    left
  if btnp(⬅️) and tail[1].x >= head.x then
    snake_direction={x=-8, y=0}
  end
  --    right
  if btnp(➡️) and tail[1].x <= head.x then
    snake_direction={x=8, y=0}
  end
  --    up
  if btnp(⬆️) and tail[1].y >= head.y then
    snake_direction={x=0, y=-8}
  end
  --    down
  if btnp(⬇️) and tail[1].y <= head.y then
    snake_direction={x=0, y=8}
  end
  -- update the position
  -- Increases the move counter
  -- and if it reached the speed goal,
  -- moves the snake
  move_counter += 1
  if move_counter >= speed then
    move_counter=0
    -- update tail position
    local new_tail = (
      (add_tail) and
      {x=tail[#tail].x, y=tail[#tail].y}
      or nil
    )
    add_tail=false
    for i=#tail, 2, -1 do
      copy_pos(tail[i-1], tail[i])
    end
    copy_pos(head, tail[1])
    -- update head position
    head.x += snake_direction.x
    head.y += snake_direction.y
    if head.x < gameboard.left then head.x = gameboard.right - 7 end
    if head.x > gameboard.right then head.x = gameboard.left end
    if head.y < gameboard.top then head.y = gameboard.bottom - 7 end
    if head.y > gameboard.bottom then head.y = gameboard.top end
    -- add new part of tail
    if new_tail then add(tail, new_tail) end
  end
  -- check for gameover
  gameover = false
  foreach(tail, function(pos)
    if hit(head, pos) then
      gameover = true
    end
  end)
  foreach(walls, function(pos)
    if hit(head, pos) then
      gameover = true
    end
  end)

  -- fruit check
  if hit(head, fruit) then
    -- Red fruits (sprite 2) grant 3 point
    -- Gellow fruits (sprite 3) grant 9 point
    score += ((fruit.kind == red_fruit_sprite)
      and 3 or 9
    )
    generate_fruit()
    -- The speed value is reduced at each tick by 0.5
    -- This way it is increased each 2 ticks
    -- Its value cannot go below 2
    if speed > 2 then speed -= 0.5 end
    add_tail=true
  end
  -- If a golden fruit is on the field,
  -- decreases its counter.
  -- When it reaches 0,
  -- a new fruit is generated
  if golden_fruit_counter > 0 then
    golden_fruit_counter -= 1
    if golden_fruit_counter == 0 then generate_fruit() end
  end
end

function _update()
  if in_game then
    update_game()
    if gameover then
      in_game = false
    end
  else
    s = update_menu(menu)
    if s then
      init_game(s)
    end
  end
end

function draw_snake()
  if head.y == tail[1].y and head.x < tail[1].x then
    spr(snake_head_h_sprite, head.x, head.y) -- left
  elseif head.y == tail[1].y and head.x > tail[1].x then
    spr(snake_head_h_sprite, head.x, head.y, 1, 1, true, false) -- right
  elseif head.x == tail[1].x and head.y < tail[1].y then
    spr(snake_head_v_sprite, head.x, head.y) -- up
  elseif head.x == tail[1].x and head.y > tail[1].y then
    spr(snake_head_v_sprite, head.x, head.y, 1, 1, false, true) -- down
  end

  local function draw_snake_body(pos, prev_pos, next_pos)
    if prev_pos.y == pos.y then
      -- previous on the left/right
      if next_pos.y == pos.y then
        -- horizontal
        spr(snake_body_h_sprite, pos.x, pos.y)
      else
        if prev_pos.x < pos.x and next_pos.y > pos.y then
          -- H T
          --   T
          spr(snake_body_d_sprite, pos.x, pos.y)
        elseif prev_pos.x < pos.x and next_pos.y < pos.y then
          --   T
          -- H T
          spr(snake_body_d_sprite, pos.x, pos.y, 1, 1, false, true)
        elseif prev_pos.x > pos.x and next_pos.y > pos.y then
          -- T H
          -- T
          spr(snake_body_d_sprite, pos.x, pos.y, 1, 1, true, false)
        elseif prev_pos.x > pos.x and next_pos.y < pos.y then
          -- T
          -- T H
          spr(snake_body_d_sprite, pos.x, pos.y, 1, 1, true, true)
        end
      end
    else
      -- previous up or down
      if next_pos.x == pos.x then
        -- vertical
        spr(snake_body_v_sprite, pos.x, pos.y)
      else
        if prev_pos.y > pos.y and next_pos.x < pos.x then
          -- T T
          --   H
          spr(snake_body_d_sprite, pos.x, pos.y)
        elseif prev_pos.y < pos.y and next_pos.x < pos.x then
          --   H
          -- T T
          spr(snake_body_d_sprite, pos.x, pos.y, 1, 1, false, true)
        elseif prev_pos.y > pos.y and next_pos.x > pos.x then
          -- T T
          -- H
          spr(snake_body_d_sprite, pos.x, pos.y, 1, 1, true, false)
        elseif prev_pos.y < pos.y and next_pos.x > pos.x then
          -- H
          -- T T
          spr(snake_body_d_sprite, pos.x, pos.y, 1, 1, true, true)
        end
      end
    end
  end
  -- First tail block
  draw_snake_body(tail[1], head, tail[2])
  -- Central tail blocks
  for i=2, #tail-1 do
    draw_snake_body(tail[i], tail[i-1], tail[i+1])
  end
  -- Last tail block
  tail_end = tail[#tail]
  tail_prev = tail[#tail-1]
  if tail_end.y == tail_prev.y and tail_end.x > tail_prev.x then
    spr(snake_tail_h_sprite, tail_end.x, tail_end.y)
  elseif tail_end.y == tail_prev.y and tail_end.x < tail_prev.x then
    spr(snake_tail_h_sprite, tail_end.x, tail_end.y, 1, 1, true, false)
  elseif tail_end.x == tail_prev.x and tail_end.y > tail_prev.y then
    spr(snake_tail_v_sprite, tail_end.x, tail_end.y)
  else
    spr(snake_tail_v_sprite, tail_end.x, tail_end.y, 1, 1, false, true)
  end
end

function _draw()
  -- draw board
  rectfill(header_rect.left, header_rect.top, header_rect.right, header_rect.bottom, header_color)
  rectfill(gameboard.left, gameboard.top, gameboard.right, gameboard.bottom, bg_color)
  
  -- gameover check
  if gameover then
    print("gameover", 46, 40, 8)
    print("score: "..score, 46, 50, 12)
  end

  if in_game then
    -- print points
    print("score: "..score, 1, 1, 12)

    draw_snake()
    -- draw fruit
    if fruit then
      spr(fruit.kind, fruit.x, fruit.y)
    end
    -- draw walls
    foreach (walls, function (wall)
      spr(wall_sprite, wall.x, wall.y)
    end)
  else
    spr(logo_sprite, 52, 20, 3, 2)
    print("select game mode:", 29, 84, 1)
    draw_menu(menu, {x=45,y=92})
  end
end
