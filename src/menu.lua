function draw_menu(menu, pos, size)
    for i=1, #menu.elements do
        rectfill(
            pos.x, pos.y, pos.x + size.w, pos.y + size.h,
            menu.selected == i and menu.bg_sel_col or menu.bg_col)
        print(menu.elements[i],
            pos.x + 2, -- 2 pixels padding from left
            pos.y + (size.h - 4) / 2, -- centered in the rectangle, the print height is 4
            menu.selected == i and menu.font_sel_col or menu.font_col)
        pos.y += size.h
    end        
end

function update_menu(menu)
    if btn(2) and menu.selected > 1 then -- up
        menu.selected -= 1
    end
    if btn(3) and menu.selected < #menu.elements then -- down
        menu.selected += 1
    end
end