// @flow strict
const { readFile, writeFile } = require('fs');
const { readStream } = require('./utils');

const buildDockerrun = async (filename/*: string*/, tag/*: string*/, port/*: number*/, configEnv/*: string*/) => {
  const dockerrun = {
    "AWSEBDockerrunVersion": "1",
    "Image": `astralatlas/cartographer:${tag}`,
    "Ports": [
      {
        "ContainerPort": port
      }
    ],
    "Command": `-config-env ${configEnv}`,
    "Volumes": [
      {
        "HostDirectory": "/var/app/current/",
        "ContainerDirectory": "/opt/cartographer/"
      }
    ]
  };

  const dockerrunString = JSON.stringify(dockerrun);
  return new Promise((resolve, reject) => {
    writeFile(filename, dockerrunString, 'utf8', (err) => {
      if (err) {
        reject(err);
      } else {
        resolve(dockerrun);
      }
    });
  });
};

if (require.main === module) {
  const filename = process.argv[2];
  const tag = process.argv[3];
  const port = parseInt(process.argv[4], 10);
  const configEnv = process.argv[5];
  buildDockerrun(filename, tag, port, configEnv);
}

module.exports = {
  buildDockerrun,
};
