import { Box, Container, Flex, Heading, Button, Text } from "@chakra-ui/react"
import { Routes, Route, Navigate, Link, useNavigate } from "react-router-dom"
import { useAuth } from "./hooks/useAuth"
import Login from "./routes/Login"
import Signup from "./routes/Signup"
import Contacts from "./routes/Contacts"
import Settings from "./routes/Settings"

function Layout({ children }: { children: React.ReactNode }) {
  const { user, logout } = useAuth()
  const navigate = useNavigate()

  const handleLogout = () => {
    logout()
    navigate("/login")
  }

  return (
    <Box minH="100vh" bg="gray.50">
      <Box as="nav" bg="white" shadow="sm" py={4}>
        <Container maxW="container.xl">
          <Flex justify="space-between" align="center">
            <Heading size="md">CRM Training</Heading>
            {user && (
              <Flex gap={4} align="center">
                <Link to="/contacts">
                  <Button variant="ghost">Contacts</Button>
                </Link>
                <Link to="/settings">
                  <Button variant="ghost">Settings</Button>
                </Link>
                <Text fontSize="sm" color="gray.600">{user.email}</Text>
                <Button variant="outline" size="sm" onClick={handleLogout}>
                  Logout
                </Button>
              </Flex>
            )}
          </Flex>
        </Container>
      </Box>
      <Container maxW="container.xl" py={8}>
        {children}
      </Container>
    </Box>
  )
}

function ProtectedRoute({ children }: { children: React.ReactNode }) {
  const { user, isLoading } = useAuth()

  if (isLoading) {
    return <Box p={8}>Loading...</Box>
  }

  if (!user) {
    return <Navigate to="/login" replace />
  }

  return <Layout>{children}</Layout>
}

export default function App() {
  return (
    <Routes>
      <Route path="/login" element={<Login />} />
      <Route path="/signup" element={<Signup />} />
      <Route
        path="/contacts"
        element={
          <ProtectedRoute>
            <Contacts />
          </ProtectedRoute>
        }
      />
      <Route
        path="/settings"
        element={
          <ProtectedRoute>
            <Settings />
          </ProtectedRoute>
        }
      />
      <Route path="/" element={<Navigate to="/contacts" replace />} />
    </Routes>
  )
}
