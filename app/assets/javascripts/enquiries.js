$(".list-group").on("click","a", function(event) {    
	var url = window.location.pathname;
	alert(url);
	$(this).parent().children().find(".active").removeClass("active")
	alert("Cunt");
	$(this).parent().children().removeClass("list-group-item");
	$(this).addClass("list-group-item active");
});