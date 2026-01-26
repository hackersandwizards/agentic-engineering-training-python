import { Box, Button, Heading, Input, Stack, Text } from "@chakra-ui/react"
import { useMutation } from "@tanstack/react-query"
import { useState } from "react"
import { useAuth } from "../hooks/useAuth"
import { api } from "../hooks/api"

export default function Settings() {
  const { user } = useAuth()
  const [fullName, setFullName] = useState(user?.full_name || "")
  const [email, setEmail] = useState(user?.email || "")
  const [currentPassword, setCurrentPassword] = useState("")
  const [newPassword, setNewPassword] = useState("")
  const [message, setMessage] = useState("")
  const [error, setError] = useState("")

  const updateProfileMutation = useMutation({
    mutationFn: (data: { full_name: string; email: string }) =>
      api.patch("/users/me", data),
    onSuccess: () => {
      setMessage("Profile updated successfully")
      setError("")
    },
    onError: (err: Error) => {
      setError(err.message)
      setMessage("")
    },
  })

  const updatePasswordMutation = useMutation({
    mutationFn: (data: { current_password: string; new_password: string }) =>
      api.patch("/users/me/password", data),
    onSuccess: () => {
      setMessage("Password updated successfully")
      setCurrentPassword("")
      setNewPassword("")
      setError("")
    },
    onError: (err: Error) => {
      setError(err.message)
      setMessage("")
    },
  })

  const handleProfileUpdate = (e: React.FormEvent) => {
    e.preventDefault()
    updateProfileMutation.mutate({ full_name: fullName, email })
  }

  const handlePasswordUpdate = (e: React.FormEvent) => {
    e.preventDefault()
    updatePasswordMutation.mutate({
      current_password: currentPassword,
      new_password: newPassword,
    })
  }

  return (
    <Stack gap={8}>
      <Heading size="lg">Settings</Heading>

      {message && (
        <Box bg="green.50" border="1px" borderColor="green.200" p={4} borderRadius="md">
          <Text color="green.700">{message}</Text>
        </Box>
      )}

      {error && (
        <Box bg="red.50" border="1px" borderColor="red.200" p={4} borderRadius="md">
          <Text color="red.700">{error}</Text>
        </Box>
      )}

      <Box bg="white" p={6} borderRadius="lg" shadow="sm">
        <form onSubmit={handleProfileUpdate}>
          <Stack gap={4}>
            <Heading size="md">Profile</Heading>

            <Box>
              <Text mb={2} fontWeight="medium">Full Name</Text>
              <Input
                value={fullName}
                onChange={(e) => setFullName(e.target.value)}
                placeholder="Your name"
              />
            </Box>

            <Box>
              <Text mb={2} fontWeight="medium">Email</Text>
              <Input
                type="email"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                placeholder="your@email.com"
              />
            </Box>

            <Button
              type="submit"
              colorScheme="blue"
              loading={updateProfileMutation.isPending}
              alignSelf="start"
            >
              Update Profile
            </Button>
          </Stack>
        </form>
      </Box>

      <Box bg="white" p={6} borderRadius="lg" shadow="sm">
        <form onSubmit={handlePasswordUpdate}>
          <Stack gap={4}>
            <Heading size="md">Change Password</Heading>

            <Box>
              <Text mb={2} fontWeight="medium">Current Password</Text>
              <Input
                type="password"
                value={currentPassword}
                onChange={(e) => setCurrentPassword(e.target.value)}
                placeholder="Current password"
                minLength={8}
              />
            </Box>

            <Box>
              <Text mb={2} fontWeight="medium">New Password</Text>
              <Input
                type="password"
                value={newPassword}
                onChange={(e) => setNewPassword(e.target.value)}
                placeholder="New password (min 8 characters)"
                minLength={8}
              />
            </Box>

            <Button
              type="submit"
              colorScheme="blue"
              loading={updatePasswordMutation.isPending}
              alignSelf="start"
            >
              Change Password
            </Button>
          </Stack>
        </form>
      </Box>
    </Stack>
  )
}
