import crypto from 'node:crypto'
import { sendType } from './types.ts'
import { Lobby } from './lobby.ts'

export const generateUniqueCode = (): string => {
	let code
	do {
		code = crypto.randomBytes(3).toString('hex').toUpperCase()
	} while (Lobby.getLobby(code) && code !== 'SERVER')
	return code
}

export const sendTraceMessage = (
	sendType: sendType | undefined,
	from: string = 'SERVER',
	to: string = 'SERVER',
	message: string,
) => {
	const safeSendType = sendType ?? 'Sending'
	const paddedSendType = safeSendType.padEnd(12)
	console.log(
		`${
			new Date().toISOString()
		} :: ${paddedSendType} :: ${from}->${to} :: ${message.trim()}`,
	)
}

function encodeValue(val: any): string {
  if (val === null || val === undefined) {
    return 'n';
  }

  switch (typeof val) {
    case 'string':
      return `s${val}#`;
    case 'number':
      return `d${val.toString()}#`;
    case 'boolean':
      return `b${val ? '1' : '0'}`;
    // deno-lint-ignore no-case-declarations
    case 'object':
      const parts: string[] = [];
      for (const [k, v] of Object.entries(val)) {
        parts.push(encodeValue(k));
        parts.push(encodeValue(v));
      }
      return `t${parts.join('')}e`;
  }
}

function decodeValue(str: string): any {
  let pos = 0;

  function decode(): any {
    if (pos >= str.length) {
      sendTraceMessage(
        sendType.Error,
        undefined,
        undefined,
        'Error: Unexpected end of input',
      )
      return null
    }

    const typ = str[pos];
    pos++;

    switch (typ) {
      case 'n':
        return null;
      case 's': {
        let value = '';
        while (pos < str.length && str[pos] !== '#') {
          value += str[pos];
          pos++;
        }
        pos++;
        return value;
      }
      case 'd': {
        let value = '';
        while (pos < str.length && str[pos] !== '#') {
          value += str[pos];
          pos++;
        }
        pos++;
        return Number(value);
      }
      // deno-lint-ignore no-case-declarations
      case 'b':
        const value = str[pos];
        pos++;
        return value === '1';
      case 't':
      case 'g': {
        const obj: { [key: string]: any } = {};
        while (pos < str.length && str[pos] !== 'e') {
          const key = decode();
          const value = decode();
          obj[key] = value;
        }
        pos++;
        return obj;
      }
    }
  }

  return decode();
}

const RESERVED_KEYS = new Set(['action', 'id', 'code', 'to', 'from']);

export function serializeNetworkingMessage(obj: { [key: string]: any }): string {
  const parts: string[] = [];

  const reservedOrder = ['action', 'id', 'code', 'to', 'from'];
  for (const key of reservedOrder) {
    if (key in obj) {
      parts.push(`${key}:${encodeValue(obj[key])}`);
    }
  }

  const sortedKeys = Object.keys(obj)
    .filter(key => !RESERVED_KEYS.has(key))
    .sort();

  for (const key of sortedKeys) {
    parts.push(`${key}:${encodeValue(obj[key])}`);
  }

  return parts.join(',');
}

export function parseNetworkingMessage(str: string): { [key: string]: any } {
  const items: { [key: string]: any } = {};

  const pairs = str.split(',');
  for (const pair of pairs) {
    const match = pair.match(/([^:]+):(.*)/);
    if (match) {
      const [, key, value] = match;
      const trimmedKey = key.trim();
      const trimmedValue = value.trim();

      items[trimmedKey] = decodeValue(trimmedValue);
    }
  }

  return items;
}
