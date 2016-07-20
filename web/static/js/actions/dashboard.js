const dashboardActions = {
    loadStats: (params) => {
        return (dispatch, getState) => {
            const { auth } = getState();
            auth.channel
                .push('dashboard_stats', params)
                .receive('ok', (msg) => {
                    dispatch({
                        type: 'DASHBOARD_LOAD_DATA',
                        data: msg,
                        lastUpdated: Date.now()
                    });
                })
                .receive('error', (msg) => {
                    console.log(msg);
                });
        };
    }
};

export default dashboardActions;
