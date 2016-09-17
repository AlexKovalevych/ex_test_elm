var _user$project$Native_Chart = function() {
    function renderAreaChart(canvasId, data)
    {
        var interval = setInterval(function() {
            var ctx = document.getElementById(canvasId);
            if (ctx === null || ctx.classList.contains('rendered')) {
                return;
            }

            ctx.setAttribute('class', 'rendered');
            var points = JSON.parse(data);
            var labels = [];
            for (var i = 0; i < points.length; i++) {
                labels.push(i);
            }
            var myChart = new Chart(ctx, {
                type: 'line',
                data: {
                    labels: labels,
                    datasets: [{
                        label: '',
                        fill: true,
                        data: points,
                        backgroundColor: 'rgba(255, 99, 132, 0.2)',
                        borderColor: 'rgba(255,99,132,1)',
                        borderWidth: 1
                    }]
                },
                options: {
                    scales: {
                        xAxes: [{
                            display: false
                        }],
                        yAxes: [{
                            display: false
                        }]
                    },
                    legend: {
                        display: false
                    },
                    tooltips: {
                        enabled: false,
                        custom: function(tooltip) {
                            console.log(tooltip);
                        }
                    },
                    title: {
                        display: false
                    }
                }
            });
            clearInterval(interval);
        }, 100);
    }

    return {
        area: F2(renderAreaChart)
    };
}();
