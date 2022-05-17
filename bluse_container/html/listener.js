/*----------------------------CREDITS------------------------------
--------        Script made by Bluse and Invrokaaah        --------
------   Copyright 2021 BluseStudios. All rights reserved   -------
-----------------------------------------------------------------*/

/* FIRST CARD */
$(function(){
	window.onload = (e) => {
        /* 'links' the js with the Nui message from main.lua */
		window.addEventListener('message', (event) => {
			var item = event.data;
			if (item !== undefined && item.type === "ui1") {
                /* if the display is true, it will show */
				if (item.display === true) {
                    $("#card1").show();
                     /* if the display is false, it will hide */
				} else{
                    $("#card1").hide();
                }
			}
		});
	};
	/* WHEN PRESS THE BUTTON close YOU LEFT THE FIRST CARD */
	$("#close").click(function () {
        $.post('http://container/exit_ui1', JSON.stringify({}));
        return
    })
	/* WHEN PRESS THE BUTTON buy YOU BUY THE CONTAINER AND CLOSE THE FIRST CARD*/
	$("#buy").click(function () {
		$.post('http://container/buy', JSON.stringify({}));
		$.post('http://container/exit_ui1', JSON.stringify({}));
		return
    })





/* ------------------------------------------------------------------------------------------------------------------------ */
/* SECOND CARD */
    /* 'links' the js with the Nui message from main.lua */
	window.addEventListener('message', (event) => {
		var item = event.data;
		if (item !== undefined && item.type === "ui2") {
            /* if the display is true, it will show */
			if (item.display === true) {
                $("#card2").show();
                 /* if the display is false, it will hide */
			} else{
                $("#card2").hide();
            }
		}
	});
	/* WHEN PRESS BUTTON WITH id="stop" THEN QUIT THE SECOND CARD AND SHOW THIRD CARD */
	$("#stop").click(function () {
        $.post('http://container/exit_ui2', JSON.stringify({}));
		$.post('http://container/open_ui3', JSON.stringify({}));
        return
    })
	/* WHEN PRESS THE open BUTTON CLOSE THE SECOND CARD AND OPEN INVENTORY */
	$("#open").click(function () {
		$.post('http://container/open', JSON.stringify({}));
		$.post('http://container/exit_ui2', JSON.stringify({}));
		return
    })





/* ------------------------------------------------------------------------------------------------------------------------ */
/* THIRD CARD */
	/* 'links' the js with the Nui message from main.lua */
	window.addEventListener('message', (event) => {
		var item = event.data;
		if (item !== undefined && item.type === "ui3") {
            /* if the display is true, it will show */
			if (item.display === true) {
                $("#card3").show();
                 /* if the display is false, it will hide */
			} else{
                $("#card3").hide();
            }
		}
	});
	/* THIS BUTTON MAKE STOP RANT AND CLOSE THIRD CARD */
	$("#stop-rent").click(function () {
		$.post('http://container/stop', JSON.stringify({}));
		$.post('http://container/exit_ui3', JSON.stringify({}));
		return
    })
	/* IF YOU DON'T WANT STOPPING THE RENT, SO CLOSE THIRD CARD */
	$("#sure").click(function () {
		$.post('http://container/exit_ui3', JSON.stringify({}));
		return
    })
});
/* ------------------------------------------------------------------------------------------------------------------------ */