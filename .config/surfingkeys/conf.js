const {
  aceVimMap,
  mapkey,
  imap,
  imapkey,
  getClickableElements,
  vmapkey,
  map,
  unmap,
  iunmap,
  cmap,
  addSearchAlias,
  removeSearchAlias,
  tabOpenLink,
  readText,
  Clipboard,
  Front,
  Hints,
  Visual,
  RUNTIME
} = api;

/** VIM-LIKE BINDINGS */
map('gT', 'E');
map('gt', 'R');
map('H', 'S');
map('L', 'D');
unmap('E');
unmap('R');
unmap('S');
unmap('D');
unmap('e');
unmap('<Alt-m>');
iunmap(':');

settings.defaultSearchEngine = 'D';
settings.caseSensitive = true;

mapkey('gE', 'Go to first activated tab', () => {
  RUNTIME('historyTab', {index: 0});
}, {repeatIgnore: true});

mapkey('gR', 'Go to last activated tab', () => {
  RUNTIME('historyTab', {index: -1});
}, {repeatIgnore: true});

//mapkey('U', 'Page Up', () => { window.scrollBy(0, -700); });
//mapkey('D', 'Page Down', () => { window.scrollBy(0, 700); });
mapkey('U', 'Page Up', () => { window.scrollTo(0, window.pageYOffset + window.innerHeight * -0.9); });
mapkey('D', 'Page Down', () => { window.scrollTo(0, window.pageYOffset + window.innerHeight * 0.9); });
mapkey(',m', 'Mute/Unmute current tab', () => { RUNTIME('muteTab'); });

/** OPEN NEW TAB PAGE (HOME) IN CURRENT TAB */
mapkey(',oh', 'Go to new tab page in current tab', () => {
  RUNTIME('openLink', {
    tab: {
      tabbed: false
    },
    url: "chrome://newtab"
  });
});

/** OPEN A NEW INCOGNITO WINDOW */
mapkey(',on', 'Open new incognito window', () => {
  RUNTIME('openIncognito', {
    url: "chrome://newtab"
  });
});

/** OPEN A LINK IN INCOGNITO WINDOW */
mapkey(',oi', 'Open a link in incognito window', () => {
  Hints.create('', function(element) {
    RUNTIME('openIncognito', {
      url: element.href
    });
  });
});

/** SELECT OPEN TABS WITH OMNIBAR */
mapkey(',t', 'Select open tab', () => {
  Front.openOmnibar({type: "Tabs"}); 
});

/** OPEN IMAGE IN NEW TAB */
mapkey(',gi', 'View image in new tab', () => {
  Hints.create("img", (i) => tabOpenLink(i.src));
});

/*
function openLinkInCurrentTab(url) {
  RUNTIME("openLink", {
    tab: {
      tabbed: false
    },
    url: url
  });
}

var favorites = function(prefix, urls) {
  for (var key in urls) {
    mapkey(
      prefix + key,
      'favorite:' + urls[key],
      "openLinkInCurrentTab('" + urls[key] + "')"
    )
  }
}

favorites(',g', {
  0: 'http://10.0.0.2:9091/transmission/web/', 
  1: 'https://mail.google.com/',
  2: 'http://www.google.com/calendar',
  3: 'https://www.google.com/contacts/#contacts',
  4: 'https://ttrss.server-speed.net/#f=-3am'
})
*/

/** SET THEME */
settings.theme = `
.sk_theme {
  font-family: Inconsolata, Charcoal, monospace;
  font-size: 10pt;
  background: #31363b;
  color: #fcfcfc;
}
.sk_theme tbody {
  color: #eff0f1;
}
.sk_theme input {
  color: #d0d0d0;
}
.sk_theme .url {
  color: #3daee9;
}
.sk_theme .annotation {
  color: #1cdc9a;
}
.sk_theme .omnibar_highlight {
  color: #1d99f3;
}
.sk_theme .omnibar_timestamp {
  color: #fdbc4b;
}
.sk_theme .omnibar_visitcount {
  color: #2ecc71;
}
.sk_theme #sk_omnibarSearchResult ul li:nth-child(odd) {
  background: #232629;
}
.sk_theme #sk_omnibarSearchResult ul li.focused {
  background: #4d4d4d;
}
#sk_status, #sk_find {
  font-size: 20pt;
}`;

Hints.style('background: initial; background-color: #fdbc4b; color: #232629;');

// CLICK `SAVE` BUTTON TO MAKE ABOVE SETTINGS TO TAKE EFFECT.
