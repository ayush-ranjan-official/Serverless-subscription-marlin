addEventListener(
    'fetch',
    event => { 
        event.respondWith(handle(event.request));
    });

async function handle(request) {
    try {
        const response = await fetch('https://api.coingecko.com/api/v3/simple/price?ids=ethereum&vs_currencies=usd');
        const data = await response.json();
        const ethPrice = data.ethereum.usd;
        return new Response(ethPrice);
    } catch (err) {
        console.log(err); 
        return new Response('Error fetching eth price');
    }
}