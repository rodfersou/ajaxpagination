// Generated by CoffeeScript 1.6.3
(function() {
  var root;

  root = typeof exports !== "undefined" && exports !== null ? exports : this;

  root.Page = function(parent, page_number) {
    var _Singleton, _base;
    _Singleton = (function() {
      function _Singleton(parent, page_number) {
        this.parent = parent;
        this.page_number = page_number;
        this.items = null;
        this.show_after_fetch = false;
        this.fetch();
        this.show = function() {
          if ((this.items != null)) {
            return this.parent.show_page_callback(this);
          } else {
            return this.show_after_fetch = true;
          }
        };
      }

      _Singleton.prototype.fetch = function() {
        if (($.zepto != null)) {
          return $.ajax({
            url: this.parent.fetch_url,
            type: 'GET',
            dataType: 'json',
            data: {
              'start': (this.page_number - 1) * this.parent.items_by_page,
              'stop': (this.page_number * this.parent.items_by_page) - 1,
              'size': this.parent.items_by_page
            },
            'complete': (function(page) {
              return function(data) {
                page.items = data;
                if (page.show_after_fetch) {
                  page.show_after_fetch = false;
                  return page.show(page);
                }
              };
            })(this)
          });
        } else {
          return $.ajax({
            url: this.parent.fetch_url,
            type: 'GET',
            dataType: 'json',
            data: {
              'start': (this.page_number - 1) * this.parent.items_by_page,
              'stop': (this.page_number * this.parent.items_by_page) - 1,
              'size': this.parent.items_by_page
            }
          }).done((function(page) {
            return function(data) {
              page.items = data;
              if (page.show_after_fetch) {
                page.show_after_fetch = false;
                return page.show();
              }
            };
          })(this));
        }
      };

      return _Singleton;

    })();
    if ((_base = parent.page_instances)[page_number] == null) {
      _base[page_number] = new _Singleton(parent, page_number);
    }
    return parent.page_instances[page_number];
  };

  root.Pagination = (function() {
    function Pagination(pagination_id, fetch_url, show_page_callback, items_by_page, total_items, pagination_visible_pages) {
      this.pagination_id = pagination_id;
      this.fetch_url = fetch_url != null ? fetch_url : '';
      this.show_page_callback = show_page_callback != null ? show_page_callback : function() {};
      this.items_by_page = items_by_page != null ? items_by_page : 1;
      this.total_items = total_items != null ? total_items : 100;
      this.pagination_visible_pages = pagination_visible_pages != null ? pagination_visible_pages : 11;
      this.current_page = this.total_items > 0 ? 1 : 0;
      this.first_item = this.total_items > 0 ? 1 : 0;
      this.last_item = this.total_items;
      this.first_page = this.total_items > 0 ? 1 : 0;
      this.total_pages = Math.round(this.total_items / this.items_by_page);
      this.last_page = this.total_pages;
      this.page_instances = {};
      this.show_page(this.first_item);
    }

    Pagination.prototype.pagination_items = function(current_page) {
      var add_page, i, pagination_visible, pagination_visible_pages, _i, _j, _k, _l, _ref, _ref1, _ref2, _ref3, _ref4, _ref5, _ref6;
      pagination_visible_pages = this.pagination_visible_pages - 2;
      pagination_visible = [];
      add_page = function(i, type, position) {
        var item;
        if (type == null) {
          type = 'page';
        }
        if (position == null) {
          position = null;
        }
        if (type === 'page') {
          item = {
            'is_link': i !== current_page,
            'number': i,
            'content': "" + i,
            'class': i === current_page ? 'current' : 'page'
          };
        } else if (type === 'prev') {
          item = {
            'is_link': true,
            'number': i,
            'content': "&#9664;",
            'class': 'prev'
          };
        } else if (type === 'next') {
          item = {
            'is_link': true,
            'number': i,
            'content': "&#9654;",
            'class': 'next'
          };
        } else if (type === 'prev_disabled') {
          item = {
            'is_link': false,
            'number': i,
            'content': "&#9664;",
            'class': 'prev disabled'
          };
        } else if (type === 'next_disabled') {
          item = {
            'is_link': false,
            'number': i,
            'content': "&#9654;",
            'class': 'next disabled'
          };
        } else if (type === 'dots') {
          item = {
            'is_link': false,
            'number': i,
            'content': "...",
            'class': 'dots'
          };
        }
        if ((position != null)) {
          return pagination_visible.splice(position, 0, item);
        } else {
          return pagination_visible.push(item);
        }
      };
      if (this.total_pages <= pagination_visible_pages) {
        for (i = _i = _ref = this.first_page; _ref <= pagination_visible_pages ? _i <= pagination_visible_pages : _i >= pagination_visible_pages; i = _ref <= pagination_visible_pages ? ++_i : --_i) {
          new root.Page(this, i);
          add_page(i);
        }
      } else {
        if (current_page <= pagination_visible_pages - 3) {
          for (i = _j = _ref1 = this.first_page, _ref2 = pagination_visible_pages - 2; _ref1 <= _ref2 ? _j <= _ref2 : _j >= _ref2; i = _ref1 <= _ref2 ? ++_j : --_j) {
            new root.Page(this, i);
            add_page(i);
          }
          add_page(0, 'dots');
          add_page(this.last_page);
        } else if (current_page >= (this.total_pages - (pagination_visible_pages - 4))) {
          for (i = _k = _ref3 = this.total_pages - (pagination_visible_pages - 3), _ref4 = this.total_pages; _ref3 <= _ref4 ? _k <= _ref4 : _k >= _ref4; i = _ref3 <= _ref4 ? ++_k : --_k) {
            new root.Page(this, i);
            add_page(i);
          }
          add_page(0, 'dots', 0);
          add_page(this.first_page, 'page', 0);
        } else {
          for (i = _l = _ref5 = current_page - (Math.floor(pagination_visible_pages / 2) - 2), _ref6 = current_page + (Math.floor(pagination_visible_pages / 2) - 2); _ref5 <= _ref6 ? _l <= _ref6 : _l >= _ref6; i = _ref5 <= _ref6 ? ++_l : --_l) {
            new root.Page(this, i);
            add_page(i);
          }
          add_page(0, 'dots', 0);
          add_page(this.first_page, 'page', 0);
          add_page(0, 'dots');
          add_page(this.last_page);
        }
      }
      if (current_page > this.first_page) {
        add_page(current_page - 1, 'prev', 0);
      } else {
        add_page(0, 'prev_disabled', 0);
      }
      if (current_page < this.last_page) {
        add_page(current_page + 1, 'next');
      } else {
        add_page(0, 'next_disabled');
      }
      return pagination_visible;
    };

    Pagination.prototype.update_pagination = function(page_number) {
      var $item, $li, $pagination, $ul, page, _i, _len, _ref, _results;
      $pagination = $(this.pagination_id);
      $pagination.html('');
      $ul = $('<ul>');
      $ul.addClass('pagination');
      $pagination.append($ul);
      _ref = this.pagination_items(page_number);
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        page = _ref[_i];
        $li = $('<li>');
        $ul.append($li);
        if (page.is_link) {
          $item = $('<a href="#">');
          $item.attr('data-page', page.number);
          $item.on('click', (function(pagination) {
            return function(e) {
              e.preventDefault();
              return pagination.show_page(parseInt($(this).attr('data-page')));
            };
          })(this));
        } else {
          $item = $('<span>');
        }
        $item.addClass(page["class"]);
        $item.html(page.content);
        _results.push($li.html($item));
      }
      return _results;
    };

    Pagination.prototype.first = function() {
      return this.show_page(this.first_item);
    };

    Pagination.prototype.last = function() {
      return this.show_page(this.last_item);
    };

    Pagination.prototype.has_prev = function() {
      return this.active_page > this.first_item;
    };

    Pagination.prototype.has_next = function() {
      return this.active_page < this.last_item;
    };

    Pagination.prototype.prev = function() {
      return this.show_page(this.active_page - 1);
    };

    Pagination.prototype.next = function() {
      return this.show_page(this.active_page + 1);
    };

    Pagination.prototype.show_page = function(page_number) {
      var page;
      this.current_page = page_number;
      page = new root.Page(this, page_number);
      page.show();
      return this.update_pagination(page_number);
    };

    return Pagination;

  })();

}).call(this);
