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
    -- Checks whether the generated position overlaps the snake
    if hit(fruit, head) then return true end
    for i=1, #tail do
      if hit(fruit, tail[i]) then return true end
    end
    return false 
  end
  gen_pos()
  while check_pos() do
    gen_pos()
  end
end

function _init()
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
  head={x=16, y=32}
  tail={}
  add(tail, {x=16,y=24})
  add(tail, {x=24,y=24})
  add(tail, {x=32,y=24})
  snake_direction={x=0, y=8}
  speed=11
  move_counter=0
  score=0
  generate_fruit()
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
  if btn(0) and tail[1].x >= head.x then
    snake_direction={x=-8, y=0}
  end
  --    right
  if btn(1) and tail[1].x <= head.x then
    snake_direction={x=8, y=0}
  end
  --    up
  if btn(2) and tail[1].y >= head.y then
    snake_direction={x=0, y=-8}
  end
  --    down
  if btn(3) and tail[1].y <= head.y then
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
  gameover = (gameover
  			or head.x < 8
     or head.x > 119
     or head.y < 8
     or head.y > 119
  )
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
  update_game()
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
  
  -- draw fruit
  if fruit then
    spr(fruit.kind, fruit.x, fruit.y)
  end
end

function _draw()
  -- draw board
  rectfill(0, 0, 127, 127, 1)
  rectfill(8, 8, 119, 119, 11)
  
  -- gameover check
  if gameover then
    print("gameover", 46, 40, 8)
    print("score: "..score, 46, 50, 12)
    return
  end

    -- print points
  print("score: "..score, 2, 122, 12)

  draw_snake()
end
