'use strict';

const puppeteer = require('puppeteer');
const path = require('path');
const fs = require('fs');

// URL to load should be passed as first parameter
// const url = process.argv[2];
const dt = process.argv[2];
// Username and password (with colon separator) should be second parameter
// const auth_string = 'admin:admin';
const auth_string = process.argv[3];
// Output file name should be third parameter
const outfile = process.argv[4];

const machineNames = ['mx3','mx5','mx11','mx13','mx14','mx15','me8','me9','ma1','ma2','ma4','me10','me11','mj1','mj2','mj3','mj4','mj5','ai1','ai2','ai4','aj2','al1','al2','ae1','ae2','ae5','ae6','ae7','ae8','ae9','ae10'];

const urlsAndPaths = machineNames.map(name => {
  const url = `https://192.168.2.3:3000/d/nLFCnaWgk/report_single?orgId=2&var-machine=${name}${dt}`;
  const pdfPath = path.join(`${outfile}`, `${name}.pdf`); // 确保目录存在或创建它
  if (!fs.existsSync(path.dirname(pdfPath))) {
    fs.mkdirSync(path.dirname(pdfPath), { recursive: true }); // 创建目录，如果不存在
  }
  return { url, pdfPath };
});




// TODO: Output an error message if number of arguments is not right or arguments are invalid

// Set the browser width in pixels. The paper size will be calculated on the basus of 96dpi,
// so 1200 corresponds to 12.5".
// const width_px = 1632;
const width_px = 1754;
// Note that to get an actual paper size, e.g. Letter, you will want to *not* simply set the pixel
// size here, since that would lead to a "mobile-sized" screen (816px), and mess up the rendering.
// Instead, set e.g. double the size here (1632px), and call page.pdf() with format: 'Letter' and
// scale = 0.5.

// Generate authorization header for basic auth
const auth_header = 'Basic ' + new Buffer.from(auth_string).toString('base64');

(async () => {
  let browser;
  try {

    browser = await puppeteer.launch({
      headless: true,
      // for docker few folks had issues. so added below line
      args: ["--no-sandbox", "--disable-setuid-sandbox"],
      ignoreHTTPSErrors: true
    });

    for (let i = 0; i < urlsAndPaths.length; i += 5) {
      const batch = urlsAndPaths.slice(i, i + 5);

      // 使用 Promise.all 来并行处理所有页面
      await Promise.all(batch.map(async ({ url, pdfPath }) => {
      
        const page = await browser.newPage();
        try{

          // Set basic auth headers
          await page.setExtraHTTPHeaders({ 'Authorization': auth_header });

          // Increase timeout from the default of 30 seconds to 120 seconds, to allow for slow-loading panels
          await page.setDefaultNavigationTimeout(120000);

          // Increasing the deviceScaleFactor gets a higher-resolution image. The width should be set to
          // the same value as in page.pdf() below. The height is not important
          await page.setViewport({
            width: width_px,
            height: 2480,
          //   height: 2500,
            deviceScaleFactor: 1,
            isMobile: false
          });

          // Wait until all network connections are closed (and none are opened withing 0.5s).
          // In some cases it may be appropriate to change this to {waitUntil: 'networkidle2'},
          // which stops when there are only 2 or fewer connections remaining.
          await page.goto(url, { waitUntil: 'networkidle0' });

          // Hide all panel description (top-left "i") pop-up handles and, all panel resize handles
          // Annoyingly, it seems you can't concatenate the two object collections into one
          await page.evaluate(() => {
            let infoCorners = document.getElementsByClassName('panel-info-corner');
            for (el of infoCorners) { el.hidden = true; };
            let resizeHandles = document.getElementsByClassName('react-resizable-handle');
            for (el of resizeHandles) { el.hidden = true; };
          });

          // // Get the height of the main canvas, and add a margin
          // var height_px = await page.evaluate(() => {
          //   return document.getElementsByClassName('react-grid-layout')[0].getBoundingClientRect().bottom;
          // }) + 20;

          // // == auto scroll to the bottom to solve long grafana dashboard start
          // async function autoScroll(page) {
          //   await page.evaluate(async () => {
          //     await new Promise((resolve, reject) => {
          //       var totalHeight = 0;
          //       var distance = 100;
          //       var height_px = document.getElementsByClassName('react-grid-layout')[0].getBoundingClientRect().bottom;
          //       var timer = setInterval(() => {
          //         var scrollHeight = height_px;

          //         // select the scrollable view
          //         // in newer version of grafana the scrollable div is 'scrollbar-view'
          //         var scrollableEl = document.querySelector('.view') || document.querySelector('.scrollbar-view');
          //         // element.scrollBy(0, distance);
          //         scrollableEl.scrollBy({
          //           top: distance,
          //           left: 0,
          //           behavior: 'smooth'
          //         });

          //         totalHeight += distance;

          //         console.log('totalHeight', totalHeight)

          //         if (totalHeight >= scrollHeight) {
          //           clearInterval(timer);
          //           resolve();
          //         }
          //       }, 300);
          //     });
          //   });
          // }

          // await autoScroll(page);
          // // == auto scroll to the bottom to solve long grafana dashboard end
          
          
          await page.pdf({
            path: pdfPath,
            printBackground: true,
          //   width: width_px + 'px',
          //   height: height_px + 'px',
            width: 1754 + 'px',
            height: 3480 + 'px',
            //    format: 'Letter', <-- see note above for generating "paper-sized" outputs
          //   format: 'A3',
            scale: 1,
            displayHeaderFooter: false,
            margin: {
              top: 0,
              right: 0,
              bottom: 0,
              left: 0,
            },
          });

        } finally {
          await page.close();
        }
      }));
    }
  } catch (error) {
    console.error('An error occurred:', error);
  } finally {
    if (browser) {
      await browser.close().catch(err => console.error('Failed to close browser:', err));
    }
  }
})();
