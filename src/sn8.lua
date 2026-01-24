function generate_fruit()
  fruit={}
  fruit.type = (
    (score>0 and score%5 == 0)
    and 3 or 2
  )
  fruit.x=(flr(rnd(13)) + 1)*8
  fruit.y=(flr(rnd(13)) + 1)*8
end

function _init()
  head={x=16, y=32}
  tail={}
  add(tail, {x=16,y=24})
  add(tail, {x=24,y=24})
  add(tail, {x=32,y=24})
  dir={x=0, y=8}
  speed=10
  speed_count=0
  score=0
  generate_fruit()
end

function copy_pos(source, dest)
  dest.x = source.x
  dest.y = source.y
end

function hit(p1, p2)
  return p1.x==p2.x and p1.y==p2.y
end

function _update()
  if gameover then
    dir={x=0, y=0}
    return
  end
  -- check input
  --    left
  if btn(0) and dir.x == 0 then
    dir={x=-8, y=0}
  end
  --    right
  if btn(1) and dir.x == 0 then
    dir={x=8, y=0}
  end
  --    up
  if btn(2) and dir.y == 0 then
    dir={x=0, y=-8}
  end
  --    down
  if btn(3) and dir.y == 0 then
    dir={x=0, y=8}
  end
  -- update the position
  speed_count += 1
  if speed_count >= speed then
    speed_count=0
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
    score += ((fruit.type==2)
      and 3 or 9
    )
    generate_fruit()
    speed -= 0.5
    add_tail=true
  end
end

function _draw()
  -- draw board
  rectfill(0, 0, 127, 127, 1)
  rectfill(8, 8, 119, 119, 3)
  -- print points
  print("score: "..score, 2, 122, 12)
  
  -- gameover check
  if gameover then
    print("gameover", 46, 2, 8)
    return
  end
  
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
    spr(fruit.type, fruit.x, fruit.y)
  end
end