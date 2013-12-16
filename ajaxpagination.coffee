root = exports ? this

root.Page = (parent, page_number) ->
    class _Singleton
        constructor: (@parent, @page_number) ->
            @items = null
            @show_after_fetch = false
            @fetch()
            @show = () ->
                if (@items?)
                    @parent.show_page_callback(@)
                else
                    @show_after_fetch = true
        fetch: ->
            if ($.zepto?)
                $.ajax
                    url: @parent.fetch_url
                    type: 'GET'
                    dataType: 'json'
                    data:
                        'start': (@page_number - 1) * @parent.items_by_page
                        'stop': ((@page_number) * @parent.items_by_page) - 1
                        'size': @parent.items_by_page
                    'complete': do (page=@)->
                        (data)->
                            page.items = data
                            if (page.show_after_fetch)
                                page.show_after_fetch = false
                                page.show(page)
            else # jquery fallback
                $.ajax
                    url: @parent.fetch_url
                    type: 'GET'
                    dataType: 'json'
                    data:
                        'start': (@page_number - 1) * @parent.items_by_page
                        'stop': ((@page_number) * @parent.items_by_page) - 1
                        'size': @parent.items_by_page
                .done do (page=@)->
                    (data)->
                        page.items = data
                        if (page.show_after_fetch)
                            page.show_after_fetch = false
                            page.show()
    parent.page_instances[page_number] ?= new _Singleton(parent, page_number)
    return parent.page_instances[page_number]

class root.Pagination
    constructor: (@pagination_id,
                  @fetch_url               ='',
                  @show_page_callback      =()->,
                  @items_by_page           =1,
                  @total_items             =100,
                  @pagination_visible_pages=9) ->
        @current_page = if @total_items > 0 then 1 else 0
        @first_item = if @total_items > 0 then 1 else 0
        @last_item = @total_items
        @first_page = if @total_items > 0 then 1 else 0
        @total_pages = Math.ceil(@total_items / @items_by_page)
        @last_page = @total_pages
        @page_instances = {}
        @show_page(@first_item)

    # update html
    pagination_items: (current_page) ->
        pagination_visible_pages = @pagination_visible_pages - 2
        pagination_visible = []
        add_page = (i, type='page', position=null) ->
            if (type == 'page')
                item =
                    'is_link': (i != current_page)
                    'number': i
                    'content': "#{i}"
                    'class': if i == current_page then 'current' else 'page'
            else if (type == 'prev')
                item =
                    'is_link': true
                    'number': i
                    'content': "&#9664;"
                    'class': 'prev'
            else if (type == 'next')
                item =
                    'is_link': true
                    'number': i
                    'content': "&#9654;"
                    'class': 'next'
            else if (type == 'prev_disabled')
                item =
                    'is_link': false
                    'number': i
                    'content': "&#9664;"
                    'class': 'prev disabled'
            else if (type == 'next_disabled')
                item =
                    'is_link': false
                    'number': i
                    'content': "&#9654;"
                    'class': 'next disabled'
            else if (type == 'dots')
                item =
                    'is_link': false
                    'number': i
                    'content': "..."
                    'class': 'dots'
            if (position?)
                pagination_visible.splice(position, 0, item)
            else
                pagination_visible.push(item)
        if (@total_pages <= pagination_visible_pages)
            for i in [@first_page..@total_pages]
                new root.Page(@, i)
                add_page(i)
        else # total_items > pagination_visible_pages
            if (current_page <= pagination_visible_pages - 3)
                for i in [@first_page..pagination_visible_pages - 2]
                    new root.Page(@, i)
                    add_page(i)
                add_page(0, 'dots')
                add_page(@last_page)
            else if (current_page >= (@total_pages - (pagination_visible_pages - 4)))
                for i in [(@total_pages - (pagination_visible_pages - 3))..@total_pages]
                    new root.Page(@, i)
                    add_page(i)
                add_page(0, 'dots', 0)
                add_page(@first_page, 'page', 0)
            else # we are in the middle
                for i in [(current_page - (Math.floor(pagination_visible_pages / 2) - 2))..(current_page + (Math.floor(pagination_visible_pages / 2) - 2))]
                    new root.Page(@, i)
                    add_page(i)
                add_page(0, 'dots', 0)
                add_page(@first_page, 'page', 0)
                add_page(0, 'dots')
                add_page(@last_page)
        if (current_page > @first_page)
            add_page(current_page - 1, 'prev', 0)
        else
            add_page(0, 'prev_disabled', 0)
        if (current_page < @last_page)
            add_page(current_page + 1, 'next')
        else
            add_page(0, 'next_disabled')
        return pagination_visible
    update_pagination: (page_number) ->
        $pagination = $(@pagination_id)
        $pagination.html('')
        $ul = $('<ul>')
        $ul.addClass('pagination')
        $pagination.append($ul)
        for page in @pagination_items(page_number)
            $li = $('<li>')
            $ul.append($li)
            if (page.is_link)
                $item = $('<a href="#">')
                $item.attr('data-page', page.number)
                $item.on(
                    'click',
                    do (pagination=@) ->
                         (e) ->
                             e.preventDefault()
                             pagination.show_page(parseInt($(@).attr('data-page')))
                )
            else
                $item = $('<span>')
            $item.addClass(page.class)
            $item.html(page.content)
            $li.html($item)
    # moves
    first: ->
        @show_page(@first_item)
    last: ->
        @show_page(@last_item)
    has_prev: ->
        @active_page > @first_item
    has_next: ->
        @active_page < @last_item
    prev: ->
        @show_page(@active_page - 1)
    next: ->
        @show_page(@active_page + 1)
    show_page: (page_number) ->
        @current_page = page_number
        page = new root.Page(@, page_number)
        page.show()
        @update_pagination(page_number)

$.extend(
    $.fn,
    ajaxpagination: (fetch_url               ='',
                     show_page_callback      =()->,
                     items_by_page           =1,
                     total_items             =100,
                     pagination_visible_pages=9)->
        return new root.Pagination('#'+$(this).attr('id'),
                                   fetch_url,
                                   show_page_callback,
                                   items_by_page,
                                   total_items,
                                   pagination_visible_pages))

