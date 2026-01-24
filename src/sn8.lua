function hit(p1, p2)
  return p1.x==p2.x and p1.y==p2.y
end

function generate_fruit()
  -- The fruit kind is used also to determine its sprite
  fruit={}
  fruit.kind = 2 -- red kind, the default
  golden_fruit_counter = 0
  if score > 0 and score % 9 == 0 then
    -- Sometimes a golden fruit might be generated
    if (flr(rnd(9)) +1) % 3 == 0 then
      fruit.kind = 3
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
  head={x=16, y=32}
  tail={}
  add(tail, {x=16,y=24})
  add(tail, {x=24,y=24})
  add(tail, {x=32,y=24})
  dir={x=0, y=8}
  speed=11
  move_counter=0
  score=0
  generate_fruit()
end

function copy_pos(source, dest)
  dest.x = source.x
  dest.y = source.y
end

function _update()
  if gameover then
    dir={x=0, y=0}
    return
  end
  -- check input
  -- If a button is pressed, it changes direction
  -- only if there is not a tail block in the next cell
  -- the head should go
  --    left
  if btn(0) and tail[1].x >= head.x then
    dir={x=-8, y=0}
  end
  --    right
  if btn(1) and tail[1].x <= head.x then
    dir={x=8, y=0}
  end
  --    up
  if btn(2) and tail[1].y >= head.y then
    dir={x=0, y=-8}
  end
  --    down
  if btn(3) and tail[1].y <= head.y then
    dir={x=0, y=8}
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
    head.x += dir.x
    head.y += dir.y
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
    score += ((fruit.kind==2)
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

function _draw()
  -- draw board
  rectfill(0, 0, 127, 127, 1)
  rectfill(8, 8, 119, 119, 3)
  
  -- gameover check
  if gameover then
    print("gameover", 46, 40, 8)
    print("score: "..score, 46, 50, 12)
    return
  end

    -- print points
  print("score: "..score, 2, 122, 12)

  -- draw snake
  spr(0, head.x, head.y)
  foreach(
  tail,
    function (p)
      spr(1, p.x, p.y)
    end
  )
  
  -- draw fruit
  if fruit then
    spr(fruit.kind, fruit.x, fruit.y)
  end
end