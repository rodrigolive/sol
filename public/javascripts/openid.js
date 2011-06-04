(function ($) {
    $.fn.openid = function (e) {
        var f;
        var g = 'openid_username';
        var h = $('#openid_inputarea').length ? $('#openid_inputarea') : $('<div id="openid_inputarea" />');
        var j = {
            txt: {
                label: 'Enter your {provider} {username}',
                username: 'username',
                title: 'Select your openID provider',
                sign: 'Sign-In'
            },
            providers: [{
                name: 'Google',
                url: 'https://www.google.com/accounts/o8/id',
                label: null,
                big: true
            }, {
                name: 'Yahoo',
                url: 'http://yahoo.com/',
                label: null,
                big: true
            }, {
                name: 'AOL',
                username_txt: 'screenname',
                url: 'http://openid.aol.com/{username}',
                big: true
            }, {
                name: 'Launchpad',
                username_txt: 'login',
                url: 'https://launchpad.net/~{username}',
                big: true
            }, {
                name: 'OpenID',
                username_txt: 'url',
                big: true
            }, {
                name: 'MyOpenID',
                url: 'http://{username}.myopenid.com/'
            }, {
                name: 'Flickr',
                url: 'http://flickr.com/{username}/'
            }, {
                name: 'Technorati',
                url: 'http://technorati.com/people/technorati/{username}/'
            }, {
                name: 'Wordpress',
                url: 'http://{username}.wordpress.com/'
            }, {
                name: 'Blogger',
                url: 'http://{username}.blogspot.com/'
            }, {
                name: 'Verisign',
                url: 'http://{username}.pip.verisignlabs.com/'
            }, {
                name: 'Vidoop',
                url: 'http://{username}.myvidoop.com/'
            }, {
                name: 'ClaimID',
                url: 'http://claimid.com/{username}'
            }, {
                name: 'LiveJournal',
                url: 'http://{username}.livejournal.com'
            }, {
                name: 'MySpace',
                url: 'http://www.myspace.com/{username}'
            }],
            cookie_expires: 6 * 30,
            cookie_path: '/',
            img_path: '/img/'
        };
        var k = function (b, c, d) {
                var a = $('<a title="' + b + '" href="#" id="btn_' + c + '" class="openid_' + d + '_btn ' + b + '" />');
                return a.click(n)
            };
        var l = function (a) {
                var b = new Date();
                b.setTime(b.getTime() + (q.cookie_expires * 24 * 60 * 60 * 1000));
                document.cookie = "openid_prov=" + a + "; expires=" + b.toGMTString() + "; path=" + q.cookie_path
            };
        var m = function () {
                var c = document.cookie.split(';');
                for (i in c) {
                    if (typeof (c[i]) != "function" && (pos = c[i].indexOf("openid_prov=")) != -1) return $.trim(c[i].slice(pos + 12))
                }
            };
        var n = function (a, b) {
                var c = $(b || this).attr('id').replace('btn_', '');
                if (!(f = q.providers[c])) return;
                if (highlight = $('#openid_highlight')) highlight.replaceWith($('#openid_highlight a')[0]);
                $('#btn_' + c).wrap('<div id="openid_highlight" />');
                l(c);
                o();
                if (f.label === null) {
                    h.text(q.txt.title);
                    if (!b) {
                        h.fadeOut();
                        t.submit()
                    }
                }
                return false
            };
        var o = function () {
                var a = (f.label || q.txt.label).replace('{username}', (f.username_txt !== undefined) ? f.username_txt : q.txt.username).replace('{provider}', f.name);
                h.empty().show().append('<span class="oidlabel">' + a + '</span><input id="' + g + '" type="text" ' + ' name="username_txt" class="Verisign"/><input type="submit" value="' + q.txt.sign + '"/>');
                $('#' + g).focus()
            };
        var p = function () {
                var a = (f.url) ? f.url.replace('{username}', $('#' + g).val()) : $('#' + g).val();
                t.append($('<input type="hidden" name="openid_identifier" value="' + a + '" />'))
            };
        var q = $.extend(j, e || {});
        var r = $('<div id="openid_btns" />');
        var s = true;
        $.each(q.providers, function (i, a) {
            if (!a.big && s) {
                r.append('<br />');
                s = false
            }
            r.append(k(a.name, i, (a.big) ? 'large' : 'small'))
        });
        var t = this;
        t.css({
            'background-image': 'none'
        });
        t.append(r).submit(p);
        r.append(h);
        if (idx = m()) n(null, '#btn_' + idx);
        else h.text(q.txt.title).show();
        return this
    }
})(jQuery);

