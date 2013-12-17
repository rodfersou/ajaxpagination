root = exports ? this

root.Page = (parent, page_number)->
    class Page
        constructor: (@parent, @page_number)->
            @items            = null
            @start            = (@page_number - 1) * @parent.items_by_page
            @stop             = ((@page_number) * @parent.items_by_page) - 1
            @size             = @parent.items_by_page
            @show_after_fetch = false
            @fetch()
            @show = ()->
                if (@parent.fetch_url == "") or
                   (@items?)
                    @parent.show_page_callback(@)
                    @parent.current_page = @page_number
                    @parent.update_pagination(@page_number)
                else
                    @show_after_fetch = true
        fetch: ->
            @parent.ajax(
                'start' : @start
                'stop'  : @stop
                'size'  : @size
                'filter': @parent.filter_text
                do (page=@)->
                    (data)->
                        page.items = data
                        if (page.show_after_fetch)
                            page.show_after_fetch = false
                            page.show(page)
            )
    parent.page_instances[page_number] ?= new Page(parent, page_number)
    return parent.page_instances[page_number]

root.Pagination = (pagination_id,
                   fetch_url         ='',
                   show_page_callback=()->,
                   items_by_page     =1,
                   total_items       =100,
                   visible_pages     =9) ->
    class Pagination
        constructor: (@pagination_id,
                      @fetch_url,
                      @show_page_callback,
                      @items_by_page,
                      @total_items,
                      @visible_pages,
                      @filter_text='') ->
            @page_instances      = {}
            @filtered_pagination = null
            @ajax(
                'info': true
                'filter': @filter_text
                do (pagination=@)->
                    (data)->
                        if (data?)
                            if (data['ITEMS_BY_PAGE']?)
                                pagination.items_by_page = parseInt(data['ITEMS_BY_PAGE'])
                            if (data['TOTAL_ITEMS']?)
                                pagination.total_items = parseInt(data['TOTAL_ITEMS'])
                            if (data['VISIBLE_PAGES']?)
                                pagination.visible_pages = parseInt(data['VISIBLE_PAGES'])
                        pagination.calc_pages()
            )
     
        calc_pages: ()->
            @current_page = if @total_items > 0 then 1 else 0
            @first_item   = if @total_items > 0 then 1 else 0
            @last_item    = @total_items
            @first_page   = if @total_items > 0 then 1 else 0
            @total_pages  = Math.ceil(@total_items / @items_by_page)
            @last_page    = @total_pages
            @show_page(@first_item)
     
        ajax: (data,
               callback)->
            if (@fetch_url != '')
                if ($.zepto?)
                    $.ajax
                        url: @fetch_url
                        type: 'GET'
                        dataType: 'json'
                        data: data
                        'complete': callback
                else # jquery fallback
                    $.ajax
                        url: @fetch_url
                        type: 'GET'
                        dataType: 'json'
                        data: data
                    .done(callback)
            else
                callback()
     
        # update pagination html
        pagination_items: (current_page) ->
            visible_pages = @visible_pages - 2
            pagination_visible = []
            add_page = (i, type='page', position=null) ->
                if (type == 'page')
                    item =
                        'is_link': (i != current_page)
                        'number' : i
                        'content': "#{i}"
                        'class'  : if i == current_page then 'current' else 'page'
                else if (type == 'prev')
                    item =
                        'is_link': true
                        'number' : i
                        'content': "&#9664;"
                        'class'  : 'prev'
                else if (type == 'next')
                    item =
                        'is_link': true
                        'number' : i
                        'content': "&#9654;"
                        'class'  : 'next'
                else if (type == 'prev_disabled')
                    item =
                        'is_link': false
                        'number' : i
                        'content': "&#9664;"
                        'class'  : 'prev disabled'
                else if (type == 'next_disabled')
                    item =
                        'is_link': false
                        'number' : i
                        'content': "&#9654;"
                        'class'  : 'next disabled'
                else if (type == 'dots')
                    item =
                        'is_link': false
                        'number' : i
                        'content': "..."
                        'class'  : 'dots'
                if (position?)
                    pagination_visible.splice(position, 0, item)
                else
                    pagination_visible.push(item)
            if (@total_pages <= visible_pages)
                for i in [@first_page..@total_pages]
                    new root.Page(@, i)
                    add_page(i)
            else # total_items > visible_pages
                if (current_page <= (Math.floor(visible_pages / 2) + 1))
                    for i in [@first_page..visible_pages - 2]
                        new root.Page(@, i)
                        add_page(i)
                    add_page(0, 'dots')
                    new root.Page(@, @last_page)
                    add_page(@last_page)
                else if (current_page > (@total_pages - (Math.floor(visible_pages / 2) + 1)))
                    for i in [(@total_pages - (visible_pages - 3))..@total_pages]
                        new root.Page(@, i)
                        add_page(i)
                    add_page(0, 'dots', 0)
                    new root.Page(@, @first_page)
                    add_page(@first_page, 'page', 0)
                else # we are in the middle
                    for i in [(current_page - (Math.floor(visible_pages / 2) - 2))..(current_page + (Math.floor(visible_pages / 2) - 2))]
                        new root.Page(@, i)
                        add_page(i)
                    add_page(0, 'dots', 0)
                    new root.Page(@, @first_page)
                    add_page(@first_page, 'page', 0)
                    add_page(0, 'dots')
                    new root.Page(@, @last_page)
                    add_page(@last_page)
            if (current_page > @first_page)
                new root.Page(@, current_page - 1)
                add_page(current_page - 1, 'prev', 0)
            else
                add_page(0, 'prev_disabled', 0)
            if (current_page < @last_page)
                new root.Page(@, current_page + 1)
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
        show_first: ()->
            @show_page(@first_page)
        show_last: ()->
            @show_page(@last_page)
        has_prev: ()->
            return (@current_page > @first_page)
        has_next: ()->
            return (@current_page < @last_page)
        show_prev: ()->
            if (@has_prev())
                @show_page(@current_page - 1)
        show_next: ()->
            if (@has_next())
                @show_page(@current_page + 1)
        show_page: (page_number)->
            page = new root.Page(@, page_number)
            page.show()
        filter: (filter_text)->
            if (filter_text == '')
                @show_page(@current_page)
            else
                @filtered_pagination = new Pagination(@pagination_id,
                                                      @fetch_url,
                                                      @show_page_callback,
                                                      @items_by_page,
                                                      @total_items,
                                                      @visible_pages,
                                                      filter_text)

    root.Pagination.instance ?= {}
    root.Pagination.instance[pagination_id] ?= new Pagination(pagination_id,
                                                              fetch_url,
                                                              show_page_callback,
                                                              items_by_page,
                                                              total_items,
                                                              visible_pages)
    return root.Pagination.instance[pagination_id]

$.extend(
    $.fn,
    ajaxpagination: (fetch_url         ='',
                     show_page_callback=()->,
                     items_by_page     =1,
                     total_items       =100,
                     visible_pages     =9)->
        paginations = (new root.Pagination('#'+$(el).attr('id'),
                                           fetch_url,
                                           show_page_callback,
                                           items_by_page,
                                           total_items,
                                           visible_pages) for el in @)
        if (paginations.length == 1)
            paginations = paginations[0]
        return paginations
)
