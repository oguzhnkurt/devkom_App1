// node shoot.js <lang> <cikis_dizini> [kare,kare,...]
const {chromium}=require('playwright'); const fs=require('fs');
const lang=process.argv[2]||'tr', out=process.argv[3], only=process.argv[4]?process.argv[4].split(',').map(Number):null;
(async()=>{
 const b=await chromium.launch({args:['--no-sandbox']});
 const p=await b.newPage({viewport:{width:1920,height:823},deviceScaleFactor:2});
 p.on('console',m=>{if(m.type()==='error')console.log('PAGE',m.text())});
 await p.goto(`http://localhost:${process.env.PORT||8791}/render.html?lang=${lang}`);
 await p.waitForFunction(()=>window.__ready,null,{timeout:60000});
 const {DURATION,FPS}=await p.evaluate(()=>window.__meta);
 const n=Math.round(DURATION*FPS); fs.mkdirSync(out,{recursive:true});
 for(const i of (only||[...Array(n).keys()])){
  await p.evaluate(t=>window.__renderFrame(t),i/FPS);
  await p.screenshot({path:`${out}/${String(i).padStart(4,'0')}.png`});
 }
 await b.close();
})().catch(e=>{console.log('ERR',e.message);process.exit(1)});
