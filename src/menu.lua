function draw_menu(menu, pos)
    max_size=0
    foreach(menu.elements, function(elem)
        if #elem > max_size then max_size = #elem end
    end)
    width = (max_size * 4) + 2
    for i=1, #menu.elements do
        rectfill(
            pos.x, pos.y, pos.x + width, pos.y + 8,
            menu.selected == i and menu.bg_sel_col or menu.bg_col)
        print(menu.elements[i],
            pos.x + 2, -- 2 pixels padding from left
            pos.y + 2, -- centered in the rectangle, the print height is 4
            menu.selected == i and menu.font_sel_col or menu.font_col)
        pos.y += 8
    end        
end

function update_menu(menu)
    if btnp(🅾️) or btnp(❎) then
        return menu.selected
    end
    if btnp(⬆️) and menu.selected > 1 then -- up
        menu.selected -= 1
        return nil
    end
    if btnp(⬇️) and menu.selected < #menu.elements then -- down
        menu.selected += 1
        return nil
    end
end