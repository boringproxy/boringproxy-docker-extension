import React from 'react';
import Button from '@mui/material/Button';
import { createDockerDesktopClient } from '@docker/extension-api-client';
import { Stack, TextField, Typography } from '@mui/material';

// Note: This line relies on Docker Desktop's presence as a host application.
// If you're running this React app in a browser, it won't work properly.
const client = createDockerDesktopClient();

function useDockerDesktopClient() {
  return client;
}

export function App() {
  const [server, setServer] = React.useState<string>("");
  const [token, setToken] = React.useState<string>("");
  const ddClient = useDockerDesktopClient();

  const run = async () => {
    ddClient.extension.vm.cli.exec("/boringproxy", [
        'client',
        '-server', server,
        '-token', token,
      ], {
      stream: {
        onOutput(data) {
          if (data.stdout) {
            console.error(data.stdout);
          } else {
            console.log(data.stderr);
          }
        },
        onError(error) {
          console.error(error);
        },
        onClose(exitCode) {
          console.log("onClose with exit code " + exitCode);
        },
      },
    });
  };

  return (
    <>
      <Typography variant="h3">boringproxy client</Typography>
      <Stack direction="column" alignItems="start" spacing={2} sx={{ mt: 4 }}>
        
        <TextField
          label="boringproxy server address"
          //sx={{ width: 480 }}
          variant="outlined"
          //minRows={5}
          //value={response ?? ''}
          onChange={e => setServer(e.target.value)}
        />
        
        <TextField
          label="boringproxy token"
          variant="outlined"
          onChange={e => setToken(e.target.value)}
        />
        
        <Button variant="contained" onClick={run}>
          Start boringproxy
        </Button>

      </Stack>
    </>
  );
}
