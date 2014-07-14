// jquery hashbang(#!)
function hasbang(){
	$('a').each(function(){
		var o = $(this), url = o.attr('href'), p = url.match('^https?://');
		var h1 = location.hostname, h2 = h1.replace(/^www\./i,'');		
			
		if (url == '#') {
			o.attr('href','javascript:void(0);');
			return;
		}
				
		if (url.match('^#!') || url.match('^javascript:'))
			return;
				
		if (!p || url.match(h1) || url.match(h2)){	
			if (p){
				url = url.substr(p[0].length);
				if(url.indexOf('/') != -1)
					url = url.substr(url.indexOf('/'));
				else
					url = ''; 
			}
			if (url.charAt(0) == '#')
				return;
			if (url.charAt(0) == '/')
				url = url.substr(1);				
			if (!url){					
				o.attr('href',location.protocol + '//'+ h1);
				return;
			}
			url = '#!'+url.replace(/\#\!/g,'');
			o.attr('href',url);
		}
	});
}