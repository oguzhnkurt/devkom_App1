const {chromium}=require('playwright');
const fs=require('fs');
const lang=process.argv[2]||'tr', fmt=process.argv[3]||'916';
const only=process.argv[4]?process.argv[4].split(',').map(Number):null;
(async()=>{
  const b=await chromium.launch({executablePath:process.env.CHROME||undefined,
    args:['--use-gl=angle','--use-angle=swiftshader','--enable-unsafe-swiftshader','--no-sandbox','--force-device-scale-factor=1']});
  const H=fmt==='11'?1080:1920;
  const p=await b.newPage({viewport:{width:1080,height:H},deviceScaleFactor:1});
  p.on('console',m=>{if(m.type()==='error')console.log('PAGE ERR',m.text())});
  await p.goto(`http://localhost:${process.env.PORT||8777}/render.html?lang=${lang}&fmt=${fmt}`,{waitUntil:'load'});
  await p.waitForFunction(()=>window.__ready||window.__error,null,{timeout:120000});
  const err=await p.evaluate(()=>window.__error); if(err){console.log('BOOT ERR',err);process.exit(1);}
  const meta=await p.evaluate(()=>window.__meta);
  const FPS=meta.FPS, total=Math.round(meta.DURATION*FPS);
  const dir=`${process.env.STAGE}/frames/${lang}_${fmt}`; fs.mkdirSync(dir,{recursive:true});
  const list = only || Array.from({length:total},(_,i)=>i);
  const t0=Date.now();
  for (const n of list){
    await p.evaluate(t=>window.__renderFrame(t), n/FPS);
    await p.screenshot({path:`${dir}/${String(n).padStart(4,'0')}.jpg`,type:'jpeg',quality:94});
    if (list.length>8 && n%30===0) {
      const el=(Date.now()-t0)/1000, done=list.indexOf(n)+1;
      console.log(`${done}/${list.length}  ${(el/done).toFixed(2)} s/kare  tahmini kalan ${Math.round(el/done*(list.length-done))} s`);
    }
  }
  console.log('bitti',(Date.now()-t0)/1000,'s ->',dir);
  await b.close();
})().catch(e=>{console.log('ERR',e.message);process.exit(1)});
