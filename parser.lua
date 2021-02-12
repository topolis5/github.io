-- kinoukr plugin

require('support')
require('video')
require('parser')



HOME = 'https://kinoukr.com'

HOME_SLASH = HOME .. '/'


function onLoad()
	print('Hello from kinoukr plugin')
	return 1
end

function onUnLoad()
	print('Bye from kinoukr plugin')
end

function onCreate(args)
	local t = {view = 'grid_poster', type = 'folder'}
	t['menu'] = {}
	if args.q ~= 'genres' then
		table.insert(t['menu'], {title = '@string/genres', mrl = '#folder/q=genres', image = '#self/list.png'})
	end
	   -- table.insert(t['menu'], {title = '@string/search', mrl = '#folder/q=search', image = '#self/search.png'})

	
	-- #stream/page=2

	if not args.q then
		local page = tonumber(args.page or 1)
         
		local genre = args.genre or '/'
		local url = HOME .. genre
		if page > 1 then
			url = url .. 'page/' .. tostring(page) .. '/'
		end
		
  
        local x = http.getz(url)
      --  x = iconv(http.get(url), 'utf-8//IGNORE', 'UTF-8')
      --  x = iconv(http.get(url), 'UTF-8', 'windows-1251//IGNORE', '$title')		
        for image, title,  url  in string.gmatch(x, '<div class="short clearfix with%-mask".-<img src="(.-)" alt="(.-)".-data%-href="(.-)"') do
		--	url = string.gsub(url, '^(.-)', 'https:')
        image = string.gsub(image, '^/', HOME_SLASH)
			
			
		  table.insert(t, {title = tolazy(title), mrl = '#stream/q=content&id=' .. url, image = image})
		end
		
		
		
          for  url, image, title  in string.gmatch(x, '<a class="collect" href="(.-)".-<img src="(.-)".-class="collect%-title">(.-)<') do
		--	url = string.gsub(url, '^(.-)', 'https:')
        image = string.gsub(image, '^/', HOME_SLASH)
			
			
		  table.insert(t, {title = tolazy(title), mrl = '#folder/genre=' .. url, image = image})
		end



		local url = '#stream/page=' .. tostring(page + 1) .. '&genre=' .. genre
		table.insert(t,{title = L'page' .. ' ' .. tostring(page + 1), mrl = url, image = '#self/next.png'})
		
	-- #folder/q=genres
	elseif args.q == 'genres' then
		t['message'] = '@string/genre'
		t['view'] = 'simple'


        table.insert(t, {title = 'Фільми', mrl = '#stream/genre=' .. '/films/'})
        table.insert(t, {title = 'Серіали', mrl = '#stream/genre=' .. '/seriess/'})
		table.insert(t, {title = 'Мультфільми', mrl = '#stream/genre=' .. '/cartoon/'})
        table.insert(t, {title = 'Мультсеріали', mrl = '#stream/genre=' .. '/cartoon-series/'})
		table.insert(t, {title = 'Новинки', mrl = '#stream/genre=' .. '/xfsearch/year/2019/'})
        table.insert(t, {title = 'Збірки фільмів', mrl = '#stream/genre=' .. '/collections.html'})
     --   table.insert(t, {title = 'Вимкнути світло', mrl = '#stream/genre=' .. '/index.php?action_skin_change=yes&skin_name=dark'})
        local x = http.getz(HOME)
		local tt = {
			'За жанрами.-<ul class="nav%-menu flex%-row">(.-)</ul>',
			'За роком.-<ul class="nav%-menu flex%-row">(.-)</ul>',
			'За країнами.-<ul class="nav%-menu flex%-row">(.-)</ul>',

		}
		
		for _, v in ipairs(tt) do
			local x = string.match(x, v)
			for genre, title in string.gmatch(x, '<a href="(.-)">(.-)</a>') do
				table.insert(t, {title = tolazy(title), mrl = '#stream/genre=' .. genre})
			end
		end
      
      --    local x = http.getz(HOME)
       -- x = iconv(x, 'WINDOWS-1251', 'UTF-8')
      --  local x = string.match(x, 'Категорії.->(.-)<.-ТОП за місяць')
     --   for gente, title in string.gmatch(x, '<a href="(.-)".->(.-)</a>') do
		--	table.insert(t, {title = tolazy(title), mrl = '#stream/genre=' .. gente})
	--	end
        
        
	-- #stream/q=content&id=https://films-2020.ru/1610-britanija-2020.html
	elseif args.q == 'content' then
		t['view'] = 'annotation'
		local x = http.getz(args.id)
       -- x = iconv(http.get(args.id), 'WINDOWS-1251', 'UTF-8')		
          t['ref'] = args.id
	
          x = string.gsub(x, 'Смотреть онлайн', '')
		t['name'] = parse_match(x,'<h1>(.-)</h1>')
		t['description'] = parse_match(x, '<div class="fdesc full%-text noselect clearfix">(.-)</div>')
			t['poster'] = args.p

		--	t['poster'] = parse_match(x,' <div class="fposter".-src="(.-)"')
	--	if t['poster'] then
		--	t['poster'] = string.gsub(t['poster'], '^/', HOME_SLASH)
	--	end
		
			
	    	t['annotation'] = parse_array(x, { 
	    	'(Рік:</span>.-)</div>', '(Жанр:</span>.-)</div>', '(Країна:</span>.-)</div>', 
'(Кінокомпанія:</span>.-)</div>', '(Режисер:</span>.-)</div>', '(В ролях:</span>.-)</div>',

})


        for title, url in string.gmatch(x, 'class="fplayer tabs%-box".-<span>(.-)<.-<iframe.-src="(.-)"') do
        
     --   url = string.gsub(url, '^(.-)', 'https:')
        
        table.insert(t, {title = title, mrl = '#stream/q=content&id=' .. url})
		end
        for title, url in string.gmatch(x, 'class="fplayer tabs%-box".-<span>(Тре.-)<.-</iframe.-<iframe.-src="(.-)"') do
        
     --   url = string.gsub(url, '^(.-)', 'https:')
        
        table.insert(t, {title = title, mrl = '#stream/q=content&id=' .. url})
		end
         for url in string.gmatch(x, 'var player = new Playerjs.-file.-(https.-m3u8)') do
        
    --    url = string.gsub(url, '^(.-)', 'https://nm1.world')
        t['view'] = 'grid'
        table.insert(t, {title = 'Смотреть', mrl = url})
		end
        for title, url in string.gmatch(x, '"title":"(.-)".-"file".-(https.-m3u8)') do
        

        t['view'] = 'grid'
        table.insert(t, {title = title, mrl = url})
		end
	elseif args.q == 'play' then
	--	return {view = 'playback', label = args.t, mrl = url, seekable = 'true', direct = 'true'}
       return video(args.url, args)
	end

	return t
end