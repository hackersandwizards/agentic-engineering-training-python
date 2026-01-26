"use client"

import { ChakraProvider, createSystem, defaultConfig } from "@chakra-ui/react"
import { type PropsWithChildren } from "react"
import { AuthProvider } from "../../hooks/useAuth"

const system = createSystem(defaultConfig, {
  globalCss: {
    body: {
      margin: 0,
      padding: 0,
    },
  },
})

export function Provider({ children }: PropsWithChildren) {
  return (
    <ChakraProvider value={system}>
      <AuthProvider>
        {children}
      </AuthProvider>
    </ChakraProvider>
  )
}
