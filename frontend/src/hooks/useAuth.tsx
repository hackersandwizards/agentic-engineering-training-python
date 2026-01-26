import { createContext, useContext, useState, useEffect, ReactNode } from "react"
import { api } from "./api"

interface User {
  id: string
  email: string
  full_name: string | null
  is_superuser: boolean
}

interface AuthContextType {
  user: User | null
  isLoading: boolean
  login: (email: string, password: string) => Promise<void>
  logout: () => void
  signup: (email: string, password: string, fullName?: string) => Promise<void>
}

const AuthContext = createContext<AuthContextType | null>(null)

export function AuthProvider({ children }: { children: ReactNode }) {
  const [user, setUser] = useState<User | null>(null)
  const [isLoading, setIsLoading] = useState(true)

  useEffect(() => {
    const token = localStorage.getItem("access_token")
    if (token) {
      api.get<User>("/users/me")
        .then(setUser)
        .catch(() => localStorage.removeItem("access_token"))
        .finally(() => setIsLoading(false))
    } else {
      setIsLoading(false)
    }
  }, [])

  const login = async (email: string, password: string) => {
    const formData = new URLSearchParams()
    formData.append("username", email)
    formData.append("password", password)

    const response = await fetch("http://localhost:8000/api/v1/login/access-token", {
      method: "POST",
      headers: { "Content-Type": "application/x-www-form-urlencoded" },
      body: formData,
    })

    if (!response.ok) {
      throw new Error("Invalid credentials")
    }

    const data = await response.json()
    localStorage.setItem("access_token", data.access_token)

    const userData = await api.get<User>("/users/me")
    setUser(userData)
  }

  const logout = () => {
    localStorage.removeItem("access_token")
    setUser(null)
  }

  const signup = async (email: string, password: string, fullName?: string) => {
    await api.post("/users/signup", {
      email,
      password,
      full_name: fullName || null,
    })
    await login(email, password)
  }

  return (
    <AuthContext.Provider value={{ user, isLoading, login, logout, signup }}>
      {children}
    </AuthContext.Provider>
  )
}

export function useAuth() {
  const context = useContext(AuthContext)
  if (!context) {
    throw new Error("useAuth must be used within an AuthProvider")
  }
  return context
}
