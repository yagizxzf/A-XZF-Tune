import {homedir} from 'node:os';
import {join} from 'node:path';
import {pathToFileURL} from 'node:url';
const skill=process.env.ROBLOX_UI_MAKER_SKILL ?? join(homedir(),'.codex','skills','roblox-ui-maker');
const {launch,SETTLE}=await import(pathToFileURL(join(skill,'scripts','cdp.mjs')).href);
const browser=await launch(9335,1920,1080);
try {
  for(const [page,name] of [['hud','desktop'],['hud_phone','mobile'],['states','states']]) {
    await browser.goto(`http://127.0.0.1:8870/${page}.html?raw`);
    const broken=await browser.eval(SETTLE); if(broken)throw Error('Broken images');
    await browser.shot(`ui/shots/${name}.png`,{x:0,y:0,width:1920,height:1080},1);
  }
}finally{browser.close();}
